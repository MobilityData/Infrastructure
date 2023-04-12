include ../../../../.engine/mk/subject.mk
include $(MK)/tech/terraform.mk
include $(MK)/tech/gh.mk

subject:
ifeq ($(ENGINE_ENV),github-pr)
	$(call run_step,terraform-plan-artifacts-produce)
	$(call run_step,gh-pr-artifacts-publish)
	$(call run_step,terraform-plan-artifacts-clean)
endif
