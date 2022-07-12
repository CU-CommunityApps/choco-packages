import boto3, os, sys

REGION = sys.argv[1]
AZ = sys.argv[2]
client = boto3.client('ec2', region_name=REGION)
# graphics_design='e3' graphics_pro='g3' graphics_g4='g4dn' standard='t2' memory='r3' compute='c4'
design=[]
pro=[]
g4=[]
base=[]
ram=[]
cpu=[]

response=client.describe_instance_type_offerings(
    LocationType='availability-zone',
    Filters=[{'Name': 'location', 'Values': [AZ]},{'Name': 'instance-type', 'Values': ['e3.*', 'g3.*', 'g4dn.*', 't2.*', 'r3.*', 'c4.*']}]
)

for i in response['InstanceTypeOfferings']:
    if 'e3' in i['InstanceType']:
        design.append(i['InstanceType'])
    if 'g3' in i['InstanceType']:
        pro.append(i['InstanceType'])
    if 'g4dn' in i['InstanceType']:
        g4.append(i['InstanceType'])
    if 't2' in i['InstanceType']:
        base.append(i['InstanceType'])
    if 'r3' in i['InstanceType']:
        ram.append(i['InstanceType'])
    if 'c4' in i['InstanceType']:
        cpu.append(i['InstanceType'])

# print(f"Graphics Design {design}")
print(f"Graphics Pro {pro}")
print(f"Graphics G4 {g4}")
print(f"Standard {base}")
print(f"Memory {ram}")
print(f"Compute {cpu}")
