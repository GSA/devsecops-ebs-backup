
"""Searches for instances with autosnapshot tag and snapshots the EBS volumes that are attached."""
#pylint: disable=F0401
import os
import collections
import datetime
from io import StringIO
import boto3

EC = boto3.client('ec2')
SNS = boto3.client('sns')
BUF = StringIO()

def lambda_handler(event, context):
    # pylint: disable=W0612,W0613
    """Default Lambda handler function"""
    logthis("Executing Lambda backup script for environment: " + os.environ['ENVIRONMENT']
            + "\n")
    reservations = EC.describe_instances(
        Filters=[
            {'Name': 'tag-key', 'Values': ['Autosnapshot', 'autosnapshot']},
        ]
    ).get(
        'Reservations', []
    )

    instances = [
        i for r in reservations
        for i in r['Instances']
    ]

    logthis("Found %d instances that need backing up" % len(instances))

    to_tag = collections.defaultdict(list)

    for instance in instances:
        try:
            retention_days = [
                int(t.get('Value')) for t in instance['Tags']
                if t['Key'] == 'Retention'][0]
        except IndexError:
            retention_days = int(os.environ['SNAPSHOT_RETENTION_DAYS'])

        for dev in instance['BlockDeviceMappings']:
            if dev.get('Ebs', None) is None:
                continue
            vol_id = dev['Ebs']['VolumeId']

            logthis("Found EBS volume %s on instance %s" % (
                vol_id, instance['InstanceId']))

            snap = EC.create_snapshot(
                VolumeId=vol_id,
            )

            to_tag[retention_days].append(snap['SnapshotId'])

            logthis("Retaining snapshot %s of volume %s from instance %s for %d days" % (
                snap['SnapshotId'],
                vol_id,
                instance['InstanceId'],
                retention_days,
            ))

    for retention_days in to_tag.keys():
        delete_date = datetime.date.today() + datetime.timedelta(days=retention_days)
        delete_fmt = delete_date.strftime('%Y-%m-%d')
        logthis("Will delete %d snapshots on %s" %
                (len(to_tag[retention_days]), delete_fmt))
        EC.create_tags(
            Resources=to_tag[retention_days],
            Tags=[
                {'Key': 'DeleteOn', 'Value': delete_fmt},
            ]
        )

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
