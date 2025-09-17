# Makefile pour le plugin Deezer ARL Spotube

# Variables de configuration
PLUGIN_NAME = deezer-arl-metadata
VERSION = 1.0.0
SRC_DIR = src
DIST_DIR = dist
BUILD_DIR = build
SEGMENTS_DIR = $(SRC_DIR)/segments

# Fichiers source
MAIN_FILE = $(SRC_DIR)/plugin.ht
SEGMENT_FILES = $(wildcard $(SEGMENTS_DIR)/*.ht)
ALL_SOURCES = $(MAIN_FILE) $(SEGMENT_FILES)

# Fichiers de sortie
OUTPUT_HETU = $(DIST_DIR)/plugin.hetu
OUTPUT_PLUGIN = $(DIST_DIR)/$(PLUGIN_NAME).smplug
PLUGIN_JSON = plugin.json

# Couleurs pour l'affichage
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: all clean build install dev check help lint format

# Cible par défaut
all: build

# Affichage de l'aide
help:
	@echo "$(BLUE)Plugin Deezer ARL pour Spotube$(NC)"
	@echo "$(BLUE)==============================$(NC)"
	@echo ""
	@echo "$(GREEN)Commandes disponibles:$(NC)"
	@echo "  $(YELLOW)make build$(NC)    - Compile le plugin"
	@echo "  $(YELLOW)make clean$(NC)    - Nettoie les fichiers temporaires"
	@echo "  $(YELLOW)make install$(NC)  - Installe le plugin dans Spotube"
	@echo "  $(YELLOW)make dev$(NC)      - Mode développement avec watch"
	@echo "  $(YELLOW)make check$(NC)    - Vérifie la syntaxe"
	@echo "  $(YELLOW)make help$(NC)     - Affiche cette aide"

# Vérification des prérequis
check-deps:
	@echo "$(BLUE)🔍 Vérification des dépendances...$(NC)"
	@which hetu >/dev/null 2>&1 || (echo "$(RED)❌ hetu_script_dev_tools non installé!$(NC)" && echo "$(YELLOW)Installez avec: dart pub global activate hetu_script_dev_tools$(NC)" && exit 1)
	@echo "$(GREEN)✅ Dépendances OK$(NC)"

# Vérification de la syntaxe
check: check-deps
	@echo "$(BLUE)🔍 Vérification de la syntaxe...$(NC)"
	@hetu check $(MAIN_FILE)
	@for file in $(SEGMENT_FILES); do \
		echo "Vérification: $$file"; \
		hetu check "$$file" || exit 1; \
	done
	@echo "$(GREEN)✅ Syntaxe correcte$(NC)"

# Préparation des dossiers
prepare-dirs:
	@mkdir -p $(DIST_DIR) $(BUILD_DIR)

# Compilation du plugin
build: check-deps prepare-dirs
	@echo "$(BLUE)🔨 Compilation du plugin $(PLUGIN_NAME) v$(VERSION)...$(NC)"
	@hetu compile $(MAIN_FILE) -o $(OUTPUT_HETU)
	@echo "$(BLUE)📦 Création de l'archive plugin...$(NC)"
	@cp $(PLUGIN_JSON) $(DIST_DIR)/
	@cd $(DIST_DIR) && zip -q -r $(PLUGIN_NAME).smplug plugin.hetu $(PLUGIN_JSON)
	@echo "$(GREEN)✅ Plugin compilé avec succès: $(OUTPUT_PLUGIN)$(NC)"
	@ls -lh $(OUTPUT_PLUGIN)

# Installation locale dans Spotube
install: build
	@echo "$(BLUE)📲 Installation du plugin dans Spotube...$(NC)"
	@if [ -d "$$HOME/.config/Spotube/plugins" ]; then \
		cp $(OUTPUT_PLUGIN) "$$HOME/.config/Spotube/plugins/"; \
		echo "$(GREEN)✅ Plugin installé dans $$HOME/.config/Spotube/plugins/$(NC)"; \
	elif [ -d "$$HOME/AppData/Roaming/Spotube/plugins" ]; then \
		cp $(OUTPUT_PLUGIN) "$$HOME/AppData/Roaming/Spotube/plugins/"; \
		echo "$(GREEN)✅ Plugin installé dans $$HOME/AppData/Roaming/Spotube/plugins/$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Dossier plugins Spotube non trouvé$(NC)"; \
		echo "$(YELLOW)   Copiez manuellement $(OUTPUT_PLUGIN) dans votre dossier plugins Spotube$(NC)"; \
	fi

# Nettoyage
clean:
	@echo "$(BLUE)🧹 Nettoyage des fichiers temporaires...$(NC)"
	@rm -rf $(DIST_DIR) $(BUILD_DIR)
	@echo "$(GREEN)✅ Nettoyage terminé$(NC)"
