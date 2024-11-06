export ARCH ?= armv7hf
VERSION ?= 12.0.0
UBUNTU_VERSION ?= 24.04
REPO ?= axisecp
SDK ?= acap-native-sdk

all: checksums filesizes

acap-native-sdk:
	touch $@

acap-native-sdk-candidate: Dockerfile
	docker build --build-arg ARCH --tag $(REPO)/$@:$(VERSION)-$(ARCH)-ubuntu$(UBUNTU_VERSION) .
	touch $@

web-server/build/_envoy: web-server/Dockerfile $(SDK)
	rm -r $(@D) ||:
	cd web-server \
	&& docker build --build-arg ARCH --build-arg SDK=$(SDK) --tag web-server . \
	&& docker cp $$(docker create web-server):/opt/monkey/examples ./build
	touch $@

%/build/_envoy: %/Dockerfile $(SDK)
	rm -r $(@D) ||:
	cd $* \
	&& docker build --build-arg ARCH --build-arg SDK=$(SDK) --tag $(notdir $*) . \
	&& docker cp $$(docker create $(notdir $*)):/opt/app ./build
	touch $@

APPS := \
	axevent/send_event/build/_envoy \
	axevent/subscribe_to_event/build/_envoy \
	axevent/subscribe_to_events/build/_envoy \
	axoverlay/build/_envoy \
	axparameter/build/_envoy \
	axserialport/build/_envoy \
	axstorage/build/_envoy \
	curl-openssl/build/_envoy \
	hello-world/build/_envoy \
	licensekey/build/_envoy \
	reproducible-package/build/_envoy \
	shell-script-example/build/_envoy \
	using-opencv/build/_envoy \
	utility-libraries/custom_lib_example/build/_envoy \
	utility-libraries/openssl_curl_example/build/_envoy \
	vapix/build/_envoy \
	vdo-opencl-filtering/build/_envoy \
	web-server-using-fastcgi/build/_envoy \
	web-server/build/_envoy \
	bounding-box/build/_envoy \
	message-broker/consume-scene-metadata/build/_envoy \
	remote-debug-example/build/_envoy

checksums: $(APPS)
	find $(^D) -name '*.eap' | xargs shasum > $@

filesizes: $(APPS)
	find $(^D) -name '*.eap' | xargs du --apparent-size > $@
