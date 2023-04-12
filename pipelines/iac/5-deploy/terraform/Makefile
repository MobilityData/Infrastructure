include ../../../../.engine/mk/subject.mk
include $(MK)/tech/terraform.mk
include $(MK)/tech/gcp-secrets.mk

subject: gcp-secrets-artifacts-produce
	$(call run_step,terraform-apply)
