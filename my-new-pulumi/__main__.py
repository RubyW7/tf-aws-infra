import pulumi
from pulumi_aws import ec2, rds

# Create VPC
vpc = ec2.Vpc('my-vpc',
              cidr_block='10.0.0.0/16',
              enable_dns_support=True,
              enable_dns_hostnames=True,
              tags={'Name': 'MyVPC'})

# Create subnets
subnet_ids = []
for i in range(1, 4):  # Creating three private subnets
    subnet = ec2.Subnet(f'private-subnet-{i}',
                        vpc_id=vpc.id,
                        cidr_block=f'10.0.{i}.0/24',
                        availability_zone=f'us-west-2{chr(96 + i)}',
                        tags={'Name': f'PrivateSubnet{i}'})
    subnet_ids.append(subnet.id)

# Create RDS instance within the private subnets
db_instance = rds.Instance('my-db-instance',
                           instance_class='db.t3.micro',
                           engine='postgres',
                           allocated_storage=20,
                           db_subnet_group_name=pulumi.Output.all(subnet_ids).apply(
                               lambda ids: my_subnet_group.name
                           ),
                           vpc_security_group_ids=[my_security_group.id],  # Ensure the SG is set up to allow the correct ingress
                           publicly_accessible=False,
                           username='csye6225',
                           password='pick_a_strong_password',
                           db_name='csye6225',
                           parameter_group_name='my-postgres-parameter-group',
                           tags={'Name': 'MyPostgresDBInstance'})

# Outputs
pulumi.export('db_instance_endpoint', db_instance.endpoint)
pulumi.export('db_instance_id', db_instance.id)
