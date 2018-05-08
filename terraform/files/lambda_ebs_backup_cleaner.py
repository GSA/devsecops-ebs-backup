
"""
This function looks at *all* snapshots that have a "DeleteOn" tag containing
the current day formatted as YYYY-MM-DD. This function should be run at least
daily.
"""
#pylint: disable=F0401
import os
import re
import datetime
from io import StringIO
import boto3

EC = boto3.client('ec2')
IAM = boto3.client('iam')
SNS = boto3.client('sns')
BUF = StringIO()

def lambda_handler(event, context):
    # pylint: disable=W0612,W0613,W0703
    """Default Lambda Handler function"""
    logthis("Executing Lambda backup cleaner script for environment: " + os.environ['ENVIRONMENT']
            + "\n")
    account_ids = list()
    try:
        account_ids.append(IAM.get_user()['User']['Arn'].split(':')[4])
    except Exception as error_message:
        # use the exception message to get the account ID the function executes under
        account_ids.append(
            re.search(r'(arn:aws:sts::)([0-9]+)', str(error_message)).groups()[1])

    delete_on = datetime.date.today().strftime('%Y-%m-%d')
    filters = [
        {'Name': 'tag-key', 'Values': ['DeleteOn']},
        {'Name': 'tag-value', 'Values': [delete_on]},
    ]
    snapshot_response = EC.describe_snapshots(
        OwnerIds=account_ids, Filters=filters)

    for snap in snapshot_response['Snapshots']:
        logthis("Deleting snapshot %s" % snap['SnapshotId'])
        EC.delete_snapshot(SnapshotId=snap['SnapshotId'])
        break
    else:
        logthis("No snapshots to delete on this run.")

    sendsns()
    BUF.close()

def logthis(loginfo):
    """Just writes to a log buffer so we can output it to SNS later. Also sends to lambda logs."""
    print(loginfo)
    BUF.write(loginfo)
    BUF.write("\n")

def sendsns():
    """Transmits the SNS"""
    SNS.publish(
        TargetArn=os.environ['SNS_LOG_ARN'],
        Message=str(BUF.getvalue())
    )
