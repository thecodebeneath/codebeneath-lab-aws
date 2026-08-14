import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"Starting reboot broker...")

    # when using a VPC endpoint for MQ services, need to override the management API endpoint
    # codebeneath-lab-mq-vpc-endpoint: private DNS names enabled=yes; Private DNS names=mq.us-east-2.api.aws
    mq = boto3.client('mq', region_name='us-east-2', endpoint_url="https://mq.us-east-2.api.aws")

    try:
        broker_name = event.get("broker_name")
        logger.info(f"Using broker_name: '{broker_name}'")
        brokers = mq.list_brokers().get("BrokerSummaries", [])
        logger.info(f"Found brokers: '{brokers}'")

        for b in brokers:
            if b.get("BrokerName") == broker_name:
                return mq.reboot_broker(BrokerId=b["BrokerId"])
        raise ValueError(f"Broker with name '{broker_name}' not found")
        logger.info(f"Complete reboot broker")

    except Exception as e:
      logger.error(f"Broker reboot function failed: {str(e)}", exc_info=True)
      raise