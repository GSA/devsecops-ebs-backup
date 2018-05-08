
"""
This function looks at *all* snapshots that have a "DeleteOn" tag containing
the current day formatted as YYYY-MM-DD. This function should be run at least
daily.
"""
#pylint: disable=F0401
import os
import re
import datetime
import boto3
from io import StringIO

EC = boto3.client('ec2')
IAM = boto3.client('iam')
SNS = boto3.client('sns')
buf = StringIO()

def lambda_handler(event, context):
    # pylint: disable=W0612,W0613,W0703
    """Default Lambda Handler function"""
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
    else:
        logthis("No snapshots to delete on this run.")

    sendsns()
    buf.close()
    

def logthis(loginfo):
    print(loginfo)
    buf.write(loginfo)
    buf.write("\n")


def sendsns():
    SNS.publish(
        TargetArn=os.environ['SNS_LOG_ARN'],
        Message=str(buf.getvalue())
    )
