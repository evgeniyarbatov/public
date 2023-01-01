import * as https from 'https';

import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand, PutCommand } from "@aws-sdk/lib-dynamodb";

const STRAVA_BASE_URL = 'www.strava.com';
const PORT = 443

const ddbClient = new DynamoDBClient({ region: process.env.DYNAMO_DB_REGION });
const ddbDocClient = DynamoDBDocumentClient.from(ddbClient);

function getTimeNow() {
    return new Date().getTime() / 1000;
}

async function getAccessToken(userId) {
    const params = {
        TableName: process.env.OAUTH_TOKEN_DYNAMO_DB,
        Key: {
          userId: userId.toString(),
        }
    };
    
    const dbResult = await ddbDocClient.send(new GetCommand(params));
    if (dbResult.Item.expires_at > getTimeNow()) {
        return dbResult.Item.access_token;
    }
     
    const path = '/oauth/token?client_id='+process.env.STRAVA_CLIENT_ID+'&client_secret='+process.env.STRAVA_CLIENT_SECRET+'&grant_type=refresh_token&refresh_token='+dbResult.Item.refresh_token;
    const result = await makeRequest('POST', path, null);
    
    await storeAccessToken(
        userId,
        result.access_token,
        result.refresh_token,
        result.expires_at,
    );
    
    return result.access_token;
}

async function storeAccessToken(userId, access_token, refresh_token, expires_at) {
    const params = {
        TableName: process.env.OAUTH_TOKEN_DYNAMO_DB,
        Item: {
          userId: userId.toString(),
          access_token: access_token,
          refresh_token: refresh_token,
          expires_at: expires_at,
        }
    };
    await ddbDocClient.send(new PutCommand(params));
}

async function storeActivity(activityId, activity) {
    console.log(`Stored ${activityId} activity`);
    const params = {
        TableName: process.env.ACTIVITY_DYNAMO_DB,
        Item: {
          activityId: activityId.toString(),
          activity: activity,
        }
    };
    await ddbDocClient.send(new PutCommand(params));
}


async function makeRequest(method, path, headers) {
    const options = {
      host: STRAVA_BASE_URL,
      path: path,
      method: method,
      port: PORT,
      headers: headers,
    };
    
    console.log(`Making request with ${JSON.stringify(options)}`);
    
    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
              var response = '';
              
              res.on('data', function (chunk) {
                response += chunk;
              });
              
              res.on('end', function () {
                resolve(JSON.parse(response));
              });
        });
        
        req.on('error', (err) => {
            reject(new Error(err));
        });
        
        req.end();
    });
}

export const handler = async(event) => {
    const method = event.requestContext.http.method;
    const path = event.requestContext.http.path;

    console.log(`Received ${method} with event ${event}`);

    switch (method) {
        case "GET":
            switch (path) {
                case "/webhook":
                    const mode = event.queryStringParameters['hub.mode'];
                    
                    const token = event.queryStringParameters['hub.verify_token'];
                    const challenge = event.queryStringParameters['hub.challenge'];

                    if (mode && token) {
                        if (mode === 'subscribe' && token === process.env.STRAVA_VERIFY_TOKEN) { 
                          return ({
                              "hub.challenge": challenge
                          });  
                        } else {
                            return {
                                statusCode: 403,
                            } 
                        }
                    }
                    break;
                case "/authorize":
                    const code = event.queryStringParameters.code;
                    
                    const path = '/oauth/token?client_id='+process.env.STRAVA_CLIENT_ID+'&client_secret='+process.env.STRAVA_CLIENT_SECRET+'&code='+code;
                    const result = await makeRequest('POST', path, null);
                    
                    await storeAccessToken(
                        result.athlete.id,
                        result.access_token,
                        result.refresh_token,
                        result.expires_at,
                    );
                    
                    return {
                        statusCode: 200,
                        body: 'AUTHORIZED',
                    }; 
            }
        case "POST":
            switch (path) {
                case "/webhook":
                    const body = JSON.parse(event.body);
                    
                    const path = '/api/v3/activities/'+body.object_id;
                    
                    const access_token = await getAccessToken(body.owner_id);         
                    const headers = {
                        'Authorization': 'Bearer ' + access_token,
                    };
    
                    const activity = await makeRequest(
                        "GET", 
                        path, 
                        headers,
                    );
                    await storeActivity(
                        body.object_id,
                        activity,
                    )
                    
                    if (activity.sport_type != 'Run') {
                        await makeRequest(
                            "PUT", 
                            path+'?hide_from_home=true',
                            headers,
                        );
                    }
                    
                    if (activity.sport_type == 'Workout') {
                        await makeRequest(
                            "PUT", 
                            path+'?name=Stretching',
                            headers,
                        );                        
                    }

                    return {
                        statusCode: 200,
                        body: 'EVENT_RECEIVED',
                    }; 
            }
    }
};
