BUILD_DIR = build
DCLS = $(BUILD_DIR)/dcls.sh
DCTAR = $(BUILD_DIR)/dctar.sh

all: $(DCLS) $(DCTAR)

clean:
	rm -rf $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(DCLS): $(BUILD_DIR) _platform.sh _mount.sh _dcls.sh
	cat $(filter-out $(BUILD_DIR),$^) > $(DCLS)
	chmod +x $(DCLS)

$(DCTAR): $(BUILD_DIR) _platform.sh _mount.sh _dctar.sh
	cat $(filter-out $(BUILD_DIR),$^) > $(DCTAR)
	chmod +x $(DCTAR)

