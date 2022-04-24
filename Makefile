RUN_TERRAFORM=docker-compose -f ./.deploy/docker-compose.yml run --rm terraform

init:
	$(RUN_TERRAFORM) init

plan:
	$(RUN_TERRAFORM) plan

output:
	$(RUN_TERRAFORM) output

apply:
	$(RUN_TERRAFORM) apply --auto-approve

destroy:
	$(RUN_TERRAFORM) destroy --auto-approve
