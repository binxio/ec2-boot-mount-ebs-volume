NAME=ec2-boot-mount-ebs-volume


create-demo: 
	@if aws cloudformation get-template-summary --stack-name $(NAME) >/dev/null 2>&1 ; then \
		export CFN_COMMAND=update; export CFN_TIMEOUT="" ;\
	else \
		export CFN_COMMAND=create; export CFN_TIMEOUT="--timeout-in-minutes 10" ;\
	fi ;\
	export VPC_ID=$$(aws ec2  --output text --query 'Vpcs[?IsDefault].VpcId' describe-vpcs) ; \
        export SUBNET_IDS=$$(aws ec2 --output text --query 'sort_by(Subnets, &AvailabilityZone)[?DefaultForAz==`true`].SubnetId' \
                                describe-subnets --filters Name=vpc-id,Values=$$VPC_ID | tr '\t' ','); \
        export SG_ID=$$(aws ec2 --output text --query "SecurityGroups[*].GroupId" \
                                describe-security-groups --group-names default  --filters Name=vpc-id,Values=$$VPC_ID); \
	echo "$$CFN_COMMAND demo in default VPC $$VPC_ID, subnets $$SUBNET_IDS using security group $$SG_ID." ; \
        ([[ -z $$VPC_ID ]] || [[ -z $$SUBNET_IDS ]] || [[ -z $$SG_ID ]]) && \
                echo "Either there is no default VPC in your account, no two subnets or no default security group available in the default VPC" && exit 1 ; \
	aws cloudformation $$CFN_COMMAND-stack --stack-name $(NAME) \
		--capabilities CAPABILITY_IAM \
		--template-body file://./cloudformation/$(NAME).yaml  \
		$$CFN_TIMEOUT \
		--parameters 	ParameterKey=VpcId,ParameterValue=$$VPC_ID \
				ParameterKey=Subnets,ParameterValue=\"$$SUBNET_IDS\" \
				ParameterKey=SecurityGroups,ParameterValue=$$SG_ID ;\
	aws cloudformation wait stack-$$CFN_COMMAND-complete --stack-name $(NAME);


delete-demo: 
	aws cloudformation delete-stack --stack-name $(NAME)
	aws cloudformation wait stack-delete-complete --stack-name $(NAME);
