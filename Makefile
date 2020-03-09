# This script deploys the Unit API.
# The hard code variable TRAVIS_PROFILE below will be overridden when deploy.sh runs
TRAVIS_PROFILE = ins-dev

# We create a function to simplify getting variables for aws parameter store.

define ssm
$(shell aws --profile $(TRAVIS_PROFILE) ssm get-parameters --names $1 --with-decryption --query Parameters[0].Value --output text)
endef

# We prepare variables for up in UPJSON and PRODUPJSON.
# These variables are comming from AWS Parameter Store
# - STAGE
# - DOMAIN
# - TRAVIS_PROFILE
# - EMAIL_FOR_NOTIFICATION_GENERIC
# - PRIVATE_SUBNET_1
# - PRIVATE_SUBNET_2
# - PRIVATE_SUBNET_3
# - DEFAULT_SECURITY_GROUP
# - LAMBDA_TO_RDS_SECURITY_GROUP

UPJSON = '.profile |= "$(TRAVIS_PROFILE)" \
		  |.stages.production |= (.domain = "unit.$(call ssm,STAGE).$(call ssm,DOMAIN)" | .zone = "$(call ssm,STAGE).$(call ssm,DOMAIN)") \
		  | .actions[0].emails |= ["unit+$(call ssm,EMAIL_FOR_NOTIFICATION_GENERIC)"] \
		  | .lambda.vpc.subnets |= [ "$(call ssm,PRIVATE_SUBNET_1)", "$(call ssm,PRIVATE_SUBNET_2)", "$(call ssm,PRIVATE_SUBNET_3)" ] \
		  | .lambda.vpc.security_groups |= [ "$(call ssm,DEFAULT_SECURITY_GROUP)", "$(call ssm,LAMBDA_TO_RDS_SECURITY_GROUP)" ]'

PRODUPJSON = '.profile |= "$(TRAVIS_PROFILE)" \
		  |.stages.production |= (.domain = "unit.$(call ssm,DOMAIN)" | .zone = "$(call ssm,DOMAIN)") \
		  | .actions[0].emails |= ["unit+$(call ssm,EMAIL_FOR_NOTIFICATION_GENERIC)"] \
		  | .lambda.vpc.subnets |= [ "$(call ssm,PRIVATE_SUBNET_1)", "$(call ssm,PRIVATE_SUBNET_2)", "$(call ssm,PRIVATE_SUBNET_3)" ] \
		  | .lambda.vpc.security_groups |= [ "$(call ssm,DEFAULT_SECURITY_GROUP)", "$(call ssm,LAMBDA_TO_RDS_SECURITY_GROUP)" ]'

# We have everything, we can run up now.
dev:
	# add more info to facilitate debugging
	# START this is `dev` in Makefile
	# The current TRAVIS_PROFILE is :
	$(TRAVIS_PROFILE)
	@echo $$AWS_ACCESS_KEY_ID
	# We replace the relevant variable in the up.json file
	# We use the template defined in up.json.in for that
	jq $(UPJSON) up.json.in > up.json
	up deploy production
	echo '# END this is dev in Makefile'

demo:
	# add more info to facilitate debugging
	# START this is `demo` in Makefile
	# The current TRAVIS_PROFILE is: 
	$(TRAVIS_PROFILE)
	# We replace the TRAVIS PROFILE variable with the correct one
	TRAVIS_PROFILE=$(call ssm,TRAVIS_PROFILE)
	@echo $$AWS_ACCESS_KEY_ID
	# We replace the relevant variable in the up.json file
	# We use the template defined in up.json.in for that
	jq $(UPJSON) up.json.in > up.json
	up deploy production
	# END this is demo in Makefile

prod:
	# add more info to facilitate debugging
	# START this is `prod` in Makefile
	# The current TRAVIS_PROFILE is: 
	$(TRAVIS_PROFILE)
	# We replace the TRAVIS PROFILE variable with the correct one
	TRAVIS_PROFILE=$(call ssm,TRAVIS_PROFILE)
	@echo $$AWS_ACCESS_KEY_ID
	# We replace the relevant variable in the up.json file
	# We use the template defined in up.json.in for that
	jq $(PRODUPJSON) up.json.in > up.json
	up deploy production
	# END this is `prod` in Makefile

test:
	curl -i -H "Authorization: Bearer $(call ssm,API_ACCESS_TOKEN)" https://unit.$(call ssm,STAGE).$(call ssm,DOMAIN)/metrics
