set shell := ["bash", "-euo", "pipefail", "-c"]

tools: mise
	@echo "All non-brew tools installed."

mise:
	@echo "Installing tools via mise"
	@mise install
	@mise reshim
