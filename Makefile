ACAP_BUILD_IMPL ?= reference

export ARCH ?= armv7hf
VERSION ?= 12.0.0
UBUNTU_VERSION ?= 24.04
REPO ?= axisecp
SDK := acap-native-sdk-$(ACAP_BUILD_IMPL)

all: checksums-$(ACAP_BUILD_IMPL)

acap-native-sdk:
	touch $@

$(SDK): $(ACAP_BUILD_IMPL).Dockerfile
	docker build \
		--build-arg ARCH \
		--tag $(REPO)/$@:$(VERSION)-$(ARCH)-ubuntu$(UBUNTU_VERSION) \
		--file $< \
		.
	touch $@

web-server/build/_envoy: web-server/Dockerfile $(SDK)
	rm -r $(@D) ||:
	cd web-server \
	&& docker build \
		--build-arg ARCH \
		--build-arg SDK=$(SDK) \
		--tag web-server \
		. \
	&& docker cp $$(docker create web-server):/opt/monkey/examples ./build-$(ACAP_BUILD_IMPL)
	touch $@

reproducible-package/build-$(ACAP_BUILD_IMPL)/_envoy: TIMESTAMP=--build-arg TIMESTAMP=0
%/build-$(ACAP_BUILD_IMPL)/_envoy: %/Dockerfile $(SDK)
	rm -r $(@D) ||:
	cd $* \
	&& docker build \
		$(TIMESTAMP) \
		--build-arg ARCH \
		--build-arg SDK=$(SDK) \
		--tag $(notdir $*) \
		. \
	&& docker cp $$(docker create $(notdir $*)):/opt/app ./build-$(ACAP_BUILD_IMPL)
	touch $@

APPS := \
	axevent/send_event/build-$(ACAP_BUILD_IMPL)/_envoy \
	axevent/subscribe_to_event/build-$(ACAP_BUILD_IMPL)/_envoy \
	axevent/subscribe_to_events/build-$(ACAP_BUILD_IMPL)/_envoy \
	axoverlay/build-$(ACAP_BUILD_IMPL)/_envoy \
	axparameter/build-$(ACAP_BUILD_IMPL)/_envoy \
	axserialport/build-$(ACAP_BUILD_IMPL)/_envoy \
	axstorage/build-$(ACAP_BUILD_IMPL)/_envoy \
	curl-openssl/build-$(ACAP_BUILD_IMPL)/_envoy \
	hello-world/build-$(ACAP_BUILD_IMPL)/_envoy \
	licensekey/build-$(ACAP_BUILD_IMPL)/_envoy \
	reproducible-package/build-$(ACAP_BUILD_IMPL)/_envoy \
	shell-script-example/build-$(ACAP_BUILD_IMPL)/_envoy \
	using-opencv/build-$(ACAP_BUILD_IMPL)/_envoy \
	utility-libraries/custom_lib_example/build-$(ACAP_BUILD_IMPL)/_envoy \
	utility-libraries/openssl_curl_example/build-$(ACAP_BUILD_IMPL)/_envoy \
	vapix/build-$(ACAP_BUILD_IMPL)/_envoy \
	vdo-opencl-filtering/build-$(ACAP_BUILD_IMPL)/_envoy \
	web-server-using-fastcgi/build-$(ACAP_BUILD_IMPL)/_envoy \
	web-server/build-$(ACAP_BUILD_IMPL)/_envoy \
	bounding-box/build-$(ACAP_BUILD_IMPL)/_envoy \
	message-broker/consume-scene-metadata/build-$(ACAP_BUILD_IMPL)/_envoy \
	remote-debug-example/build-$(ACAP_BUILD_IMPL)/_envoy

checksums-$(ACAP_BUILD_IMPL): $(APPS)
	find $(^D) -name '*.eap' | xargs shasum | sed 's/-$(ACAP_BUILD_IMPL)//' > $@
