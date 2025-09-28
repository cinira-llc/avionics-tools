DIST_DIR = dist
DCLS = $(DIST_DIR)/dcls.sh
DCTAR = $(DIST_DIR)/dctar.sh

all: $(DCLS) $(DCTAR)

clean:
	rm -rf $(DIST_DIR)

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

$(DCLS): $(DIST_DIR) _platform.sh _mount.sh _dcls.sh
	cat $(filter-out $(DIST_DIR),$^) > $(DCLS)
	chmod +x $(DCLS)

$(DCTAR): $(DIST_DIR) _platform.sh _mount.sh _dctar.sh
	cat $(filter-out $(DIST_DIR),$^) > $(DCTAR)
	chmod +x $(DCTAR)
