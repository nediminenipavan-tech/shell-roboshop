#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0a6fb7b3161cf099d" # replace with your SG ID
ZONE_ID="Z0048064LID2MWLWZVV8" # replace with your ID
DOMAIN_NAME="daws86pavan.cyou"
 for instance in $@
 do 
   INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0a6fb7b3161cf099d --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

   # Get private IP
   if [ $instance != "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
  RECORD_NAME="$instance.$DOMAIN_NAME" # mongodb.daws86pavan.cyou
 else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
  RECORD_NAME="$DOMAIN_NAME" # mongodb.daws86pavan.cyou 
  fi

 echo "$instance:$IP"
 
  aws route53 change-resource-record-sets \
   --hosted-zone-id $ZONE_ID \
   --change-batch '
   {
    "Comment": "Updating record set"
    ,Changes": [{
    "Action"               : "UPSERT"
    ,"ResourcesRecordSet"  : {
       "Name"             : "'$RECORD_NAME'"
       ,"Type"             : "A"
       ,TTL"              : 1
       ,ResourceRecords"   : [{
        "Value"      : "'$IP'"
        }]
        }
        }]
        }
        '
      done  


