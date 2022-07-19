DEPLOY_ENV ?= undefined
include deploy_envs/$(DEPLOY_ENV)-envs.mak
.PHONY: all
all: init plan apply
%_environment: deploy_envs/%/terraform.tfvars env_symlinks
	@echo "********************************************************"
	@echo "       Configuring for $* deployment"
	@echo "********************************************************"
undefined_environment:
	@echo "********************************************************"
	@echo "*       Please set the DEPLOY_ENV variable             *"
	@echo "********************************************************"
	@exit -1
env_symlinks: deploy_envs/${DEPLOY_ENV}/provider.tf
	@echo "********************************************************"
	@echo "     Cleaning up Symlinks from previous deployment"
	@echo "********************************************************"
	find . -type l -maxdepth 1 -print -exec rm {} \;
	for tffile in deploy_envs/${DEPLOY_ENV}/*.tf; \
	do \
		ln -s $${tffile} $$(basename $${tffile}); \
	done
init: ${DEPLOY_ENV}_environment
	rm -rf .terraform/modules/
	terraform init -reconfigure \
	    -backend-config="resource_group_name=${resource_group_name}" \
		-backend-config="storage_account_name=${storage_account_name}" \
		-backend-config="container_name=${container_name}" \
		-backend-config="key=${key}"
plan: init
	terraform plan -refresh=true -var-file=deploy_envs/${DEPLOY_ENV}/terraform.tfvars
apply: init
	terraform apply -auto-approve -var-file=deploy_envs/${DEPLOY_ENV}/terraform.tfvars
check: init
	terraform plan -detailed-exitcode -var-file=deploy_envs/${DEPLOY_ENV}/terraform.tfvars
destroy: init
	terraform destroy --auto-approve -var-file=deploy_envs/${DEPLOY_ENV}/terraform.tfvars
docs:
	terraform-docs md . > README.md
valid:
	tflint
	terraform fmt -check=true -diff=true -var-file=deploy_envs/${DEPLOY_ENV}/terraform.tfvars
taint:
	terraform state list -var-file=deploy_envs/${DEPLOY_ENV}/terraform.tfvars | \
		grep aws_instance | \
		sed -E -e 's/module\.([[:alnum:]_-]+)\./\1 /' -e 's/\[/\./' -e 's/\]//' | \
		while read module resource; do \
			terraform taint -var-file=deploy_envs/${DEPLOY_ENV}/terraform.tfvars -module=$$module $$resource; \
		done
redeploy: taint build