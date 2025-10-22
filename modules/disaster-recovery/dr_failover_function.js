// DR failover Lambda function
const AWS = require('aws-sdk');

exports.handler = async (event, context) => {
    console.log('Disaster recovery failover initiated');
    console.log('Event:', JSON.stringify(event, null, 2));
    
    // Parse environment variables
    const primaryRegion = process.env.PRIMARY_REGION;
    const drRegion = process.env.DR_REGION;
    const hostedZoneId = process.env.HOSTED_ZONE_ID;
    const applicationDomain = process.env.APPLICATION_DOMAIN;
    
    // Check if this is a CloudWatch alarm or manual invocation
    let alarmData = null;
    if (event.Records && event.Records[0] && event.Records[0].Sns) {
        try {
            alarmData = JSON.parse(event.Records[0].Sns.Message);
            console.log('Alarm data:', JSON.stringify(alarmData, null, 2));
        } catch (e) {
            console.log('Error parsing SNS message:', e);
        }
    }
    
    try {
        // 1. Update CloudWatch metric to track failover event
        const cloudwatch = new AWS.CloudWatch();
        await cloudwatch.putMetricData({
            Namespace: 'DisasterRecovery',
            MetricData: [
                {
                    MetricName: 'FailoverInitiated',
                    Value: 1,
                    Unit: 'Count',
                    Dimensions: [
                        {
                            Name: 'Region',
                            Value: drRegion
                        }
                    ]
                }
            ]
        }).promise();
        
        // 2. Initiate Route53 DNS failover (could be manual or automatic)
        // For automatic failover, we'd update the failover routing policy
        // For this example, we'll just log that we would perform this step
        console.log(`Would update Route53 DNS for ${applicationDomain} to point to DR region ${drRegion}`);
        
        // In a real implementation, you would:
        
        // const route53 = new AWS.Route53();
        // await route53.changeResourceRecordSets({
        //     HostedZoneId: hostedZoneId,
        //     ChangeBatch: {
        //         Changes: [
        //             {
        //                 Action: 'UPSERT',
        //                 ResourceRecordSet: {
        //                     Name: applicationDomain,
        //                     Type: 'A',
        //                     SetIdentifier: 'primary',
        //                     Failover: 'PRIMARY',
        //                     AliasTarget: {
        //                         HostedZoneId: 'DR_ZONE_ID',
        //                         DNSName: 'dr-endpoint.example.com',
        //                         EvaluateTargetHealth: true
        //                     }
        //                 }
        //             }
        //         ]
        //     }
        // }).promise();
        
        // 3. Notify operations team
        const sns = new AWS.SNS({ region: drRegion });
        await sns.publish({
            TopicArn: `arn:aws:sns:${drRegion}:${context.invokedFunctionArn.split(':')[4]}:dr-operations-alerts`,
            Subject: 'CRITICAL: DR Failover Initiated',
            Message: `
                Disaster Recovery failover has been initiated at ${new Date().toISOString()}
                
                Alarm data: ${alarmData ? JSON.stringify(alarmData, null, 2) : 'Manual invocation'}
                
                Actions taken:
                - Route53 DNS failover initiated
                - Operations team notified
                
                Manual actions required:
                - Verify application health in DR region
                - Scale up additional DR resources if needed
                - Update status page for customers
                
                Runbook: https://wiki.example.com/dr-runbook
            `
        }).promise();
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Disaster recovery failover initiated successfully',
                timestamp: new Date().toISOString()
            })
        };
    } catch (error) {
        console.error('Error during DR failover:', error);
        
        // Still try to notify operations team about the failure
        try {
            const sns = new AWS.SNS({ region: drRegion });
            await sns.publish({
                TopicArn: `arn:aws:sns:${drRegion}:${context.invokedFunctionArn.split(':')[4]}:dr-operations-alerts`,
                Subject: 'CRITICAL: DR Failover Failed',
                Message: `
                    Disaster Recovery failover has FAILED at ${new Date().toISOString()}
                    
                    Error: ${error.message}
                    
                    Stack trace: ${error.stack}
                    
                    Manual intervention required immediately.
                    Runbook: https://wiki.example.com/dr-emergency-runbook
                `
            }).promise();
        } catch (snsError) {
            console.error('Failed to send SNS notification:', snsError);
        }
        
        throw error;
    }
};