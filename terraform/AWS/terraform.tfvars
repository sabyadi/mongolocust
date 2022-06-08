#####################
# AWS Configuration #
##################### 
#AWS region which will be used for deploying Locust on AWS EC2. Use one of the following codes: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
region = "eu-central-1"
awsProfile = "private"

# VPC and subnet needs to be available before running terraform
awsVpcId                  = "vpc-976afafe"
awsSubnetId               = "subnet-8f523fe6"

# keyName refers to the ssh key file which must be present in the selected AWS region
keyName = "timo_private" 

# Must contain the absoult path in order to be usable for an ssh connection
keyPath = "/Users/timo.lackmann/Downloads/timo_private.pem"

########################
# Locust Configuration #
########################
# Instances for the Lokust deployment and the networking for the private endpoint
locustMasterInstanceType = "m5.large"
locustWorkerInstanceType  = "m5.2xlarge"
workernodeCount           = 1
workersPerNode            = 8 #recommended to be the same number as vCPUs of the instance

# Provide Locust related files to be copied to master and workers. Does not need to be provided if using the default files
#locustFiles = ["decimal_codec.py", "load_test.py", "main.py", "mongo_user.py", "settings.py"]
# Provide Locust file for execution. Must be included in 'locustFiles'. Does not need to be provided if using the default files
#locustExecuteFile = "load_test.py"


###############################
# Atlas Cluster Configuration #
###############################

# API keys must be whitelisted for your laptops IP address
# Region of Atlas deployment. Currently only AWS is supported. Use one of the following codes: https://docs.atlas.mongodb.com/reference/amazon-aws/#std-label-amazon-aws
atlasRegion = "EU_CENTRAL_1"
atlasPublicApiKey      = "duqauxtw"
atlasPrivateApiKey     = "490e5eb3-15c4-4a9f-a321-7307e28464b1"
atlasProjectId         = "5e581508a68df07ac44cd051"
atlasNumShards         = 1 #currently only 1 shard supported
atlasmajorVersion      = "5.0"
atlasMSize             = "M30"
retryableWritesEnabled = true
writeConcern           = "majority"
diskSizeGb             = 20
