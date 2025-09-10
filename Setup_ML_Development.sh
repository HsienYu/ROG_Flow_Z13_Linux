#!/bin/bash

# Setup_ML_Development.sh - Machine Learning Development Environment for ASUS ROG Flow Z13
# Author: GitHub Copilot
# Version: 1.0.0
# Date: September 11, 2025
# Prerequisite: Ubuntu 25.10 installed via Install_Ubuntu25.10.sh

set -e  # Exit on any error

# --- Colors and Global Vars ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
INSTALL_PYTHON_ML=""
INSTALL_R_STATS=""
INSTALL_DOCKER=""
INSTALL_JUPYTER=""
INSTALL_VSCODE=""
INSTALL_ROCM=""
INSTALL_CUDA=""
USERNAME=""

# --- Helper Functions ---
print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# --- Configuration Function ---
configure_ml_setup() {
    print_header "ASUS ROG Flow Z13 - Machine Learning Development Setup"
    
    # Get current username
    if [[ -n "$SUDO_USER" ]]; then
        USERNAME="$SUDO_USER"
    else
        USERNAME=$(whoami)
    fi
    print_status "Setting up ML environment for user: $USERNAME"
    
    echo "ML Development Components:"
    echo "1) Python ML Stack (NumPy, Pandas, Scikit-learn, Matplotlib)"
    read -p "Install Python ML essentials? (Y/n): " INSTALL_PYTHON_ML
    INSTALL_PYTHON_ML=${INSTALL_PYTHON_ML:-Y}
    
    echo "2) Deep Learning Frameworks (PyTorch, TensorFlow, JAX)"
    read -p "Install deep learning frameworks? (Y/n): " INSTALL_DL
    INSTALL_DL=${INSTALL_DL:-Y}
    
    echo "3) Jupyter Lab/Notebook Development Environment"
    read -p "Install Jupyter ecosystem? (Y/n): " INSTALL_JUPYTER
    INSTALL_JUPYTER=${INSTALL_JUPYTER:-Y}
    
    echo "4) Visual Studio Code with ML extensions"
    read -p "Install VSCode with ML extensions? (Y/n): " INSTALL_VSCODE
    INSTALL_VSCODE=${INSTALL_VSCODE:-Y}
    
    echo "5) Docker for containerized ML workflows"
    read -p "Install Docker? (y/N): " INSTALL_DOCKER
    INSTALL_DOCKER=${INSTALL_DOCKER:-N}
    
    echo "6) R and RStudio for statistical computing"
    read -p "Install R/RStudio? (y/N): " INSTALL_R_STATS
    INSTALL_R_STATS=${INSTALL_R_STATS:-N}
    
    # GPU Acceleration (Z13 has AMD Radeon graphics)
    echo "7) ROCm for AMD GPU acceleration (recommended for Z13)"
    read -p "Install ROCm for AMD GPU support? (Y/n): " INSTALL_ROCM
    INSTALL_ROCM=${INSTALL_ROCM:-Y}
    
    echo ""
    print_header "Configuration Summary"
    echo "Python ML: $INSTALL_PYTHON_ML"
    echo "Deep Learning: $INSTALL_DL" 
    echo "Jupyter: $INSTALL_JUPYTER"
    echo "VSCode: $INSTALL_VSCODE"
    echo "Docker: $INSTALL_DOCKER"
    echo "R/RStudio: $INSTALL_R_STATS"
    echo "ROCm (AMD GPU): $INSTALL_ROCM"
    echo ""
    
    read -p "Proceed with ML setup? (Y/n): " confirm
    confirm=${confirm:-Y}
    [[ $confirm != "Y" && $confirm != "y" ]] && { print_error "Setup cancelled."; exit 1; }
}

# --- System Updates and Prerequisites ---
setup_prerequisites() {
    print_header "Setting Up Prerequisites"
    
    # Update system
    print_status "Updating system packages..."
    apt-get update && apt-get upgrade -y
    
    # Essential development tools
    print_status "Installing essential development tools..."
    apt-get install -y build-essential git curl wget software-properties-common
    apt-get install -y python3 python3-pip python3-venv python3-dev
    apt-get install -y pkg-config libhdf5-dev libopenblas-dev
    
    print_status "Prerequisites installed successfully."
}

# --- Python ML Stack ---
setup_python_ml() {
    if [[ $INSTALL_PYTHON_ML =~ ^[Yy]$ ]]; then
        print_header "Installing Python ML Stack"
        
        # Core scientific computing
        print_status "Installing NumPy, SciPy, Pandas..."
        sudo -u $USERNAME pip3 install --user numpy scipy pandas matplotlib seaborn
        
        # Machine learning libraries
        print_status "Installing Scikit-learn and related tools..."
        sudo -u $USERNAME pip3 install --user scikit-learn scikit-image
        sudo -u $USERNAME pip3 install --user plotly bokeh altair
        
        # Data processing and utilities
        print_status "Installing data processing tools..."
        sudo -u $USERNAME pip3 install --user requests beautifulsoup4 lxml
        sudo -u $USERNAME pip3 install --user openpyxl xlrd h5py
        
        print_status "Python ML stack installed successfully."
    fi
}

# --- Deep Learning Frameworks ---
setup_deep_learning() {
    if [[ $INSTALL_DL =~ ^[Yy]$ ]]; then
        print_header "Installing Deep Learning Frameworks"
        
        # PyTorch with ROCm support (for AMD GPUs)
        if [[ $INSTALL_ROCM =~ ^[Yy]$ ]]; then
            print_status "Installing PyTorch with ROCm support..."
            sudo -u $USERNAME pip3 install --user torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.7
        else
            print_status "Installing PyTorch (CPU only)..."
            sudo -u $USERNAME pip3 install --user torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
        fi
        
        # TensorFlow
        print_status "Installing TensorFlow..."
        sudo -u $USERNAME pip3 install --user tensorflow
        
        # Additional ML frameworks
        print_status "Installing additional frameworks..."
        sudo -u $USERNAME pip3 install --user transformers datasets accelerate
        sudo -u $USERNAME pip3 install --user lightning tensorboard wandb
        
        print_status "Deep learning frameworks installed successfully."
    fi
}

# --- Jupyter Environment ---
setup_jupyter() {
    if [[ $INSTALL_JUPYTER =~ ^[Yy]$ ]]; then
        print_header "Installing Jupyter Environment"
        
        print_status "Installing Jupyter Lab and extensions..."
        sudo -u $USERNAME pip3 install --user jupyterlab jupyter notebook
        sudo -u $USERNAME pip3 install --user ipywidgets ipykernel
        
        # Jupyter extensions for ML
        print_status "Installing Jupyter extensions..."
        sudo -u $USERNAME pip3 install --user jupyterlab-git jupyterlab-lsp
        sudo -u $USERNAME pip3 install --user nbconvert nbformat
        
        # Set up kernel
        sudo -u $USERNAME python3 -m ipykernel install --user --name=python3
        
        print_status "Jupyter environment installed successfully."
        print_warning "Start Jupyter Lab with: jupyter lab"
    fi
}

# --- Visual Studio Code ---
setup_vscode() {
    if [[ $INSTALL_VSCODE =~ ^[Yy]$ ]]; then
        print_header "Installing Visual Studio Code"
        
        # Add Microsoft repository
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
        
        apt-get update
        apt-get install -y code
        
        # Install ML extensions for VSCode (as user)
        print_status "Installing VSCode ML extensions..."
        sudo -u $USERNAME code --install-extension ms-python.python
        sudo -u $USERNAME code --install-extension ms-toolsai.jupyter
        sudo -u $USERNAME code --install-extension ms-python.pylint
        sudo -u $USERNAME code --install-extension ms-python.black-formatter
        
        print_status "VSCode with ML extensions installed successfully."
    fi
}

# --- Docker for ML ---
setup_docker() {
    if [[ $INSTALL_DOCKER =~ ^[Yy]$ ]]; then
        print_header "Installing Docker"
        
        # Install Docker
        apt-get install -y docker.io docker-compose
        systemctl enable docker
        systemctl start docker
        
        # Add user to docker group
        usermod -aG docker $USERNAME
        
        print_status "Docker installed successfully."
        print_warning "Log out and back in for Docker group changes to take effect."
    fi
}

# --- R and RStudio ---
setup_r_stats() {
    if [[ $INSTALL_R_STATS =~ ^[Yy]$ ]]; then
        print_header "Installing R and RStudio"
        
        # Add R repository
        wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
        add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
        
        apt-get update
        apt-get install -y r-base r-base-dev
        
        # Install RStudio Desktop
        wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.12.1-402-amd64.deb
        dpkg -i rstudio-2023.12.1-402-amd64.deb
        apt-get install -f -y
        rm rstudio-2023.12.1-402-amd64.deb
        
        print_status "R and RStudio installed successfully."
    fi
}

# --- ROCm for AMD GPU ---
setup_rocm() {
    if [[ $INSTALL_ROCM =~ ^[Yy]$ ]]; then
        print_header "Installing ROCm for AMD GPU Support"
        
        # Add ROCm repository
        wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key | apt-key add -
        echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/5.7/ ubuntu main' | tee /etc/apt/sources.list.d/rocm.list
        
        apt-get update
        apt-get install -y rocm-dev rocm-libs rocm-utils
        
        # Add user to render group for GPU access
        usermod -aG render $USERNAME
        
        # Set environment variables
        echo 'export PATH=$PATH:/opt/rocm/bin' >> /home/$USERNAME/.bashrc
        echo 'export ROC_ENABLE_PRE_VEGA=1' >> /home/$USERNAME/.bashrc
        
        print_status "ROCm installed successfully."
        print_warning "Reboot recommended for ROCm to work properly."
    fi
}

# --- Z13 Optimizations for ML ---
apply_z13_ml_optimizations() {
    print_header "Applying Z13-Specific ML Optimizations"
    
    # Memory and CPU optimizations for ML workloads
    cat >> /etc/sysctl.conf << EOF

# ML Development optimizations for Z13
vm.swappiness=10
vm.dirty_ratio=15
vm.dirty_background_ratio=5
kernel.sched_migration_cost_ns=5000000
EOF
    
    # Create ML workspace directory
    sudo -u $USERNAME mkdir -p /home/$USERNAME/{ML_Projects,Datasets,Models,Notebooks}
    
    # Create startup script for ML environment
    cat > /home/$USERNAME/start_ml_env.sh << 'EOF'
#!/bin/bash
# ML Environment Startup Script for Z13

echo "Starting ML Development Environment on ROG Flow Z13..."

# Set performance mode for training
if command -v asusctl &> /dev/null; then
    echo "Setting performance mode..."
    sudo asusctl profile -P Performance
fi

# Check GPU availability
if command -v rocm-smi &> /dev/null; then
    echo "ROCm GPU Status:"
    rocm-smi
fi

# Start Jupyter Lab if installed
if command -v jupyter &> /dev/null; then
    echo "Starting Jupyter Lab..."
    cd ~/ML_Projects
    jupyter lab --no-browser --ip=0.0.0.0 --port=8888 &
    echo "Jupyter Lab available at: http://localhost:8888"
fi

echo "ML Environment ready!"
EOF
    
    chmod +x /home/$USERNAME/start_ml_env.sh
    chown $USERNAME:$USERNAME /home/$USERNAME/start_ml_env.sh
    
    print_status "Z13 ML optimizations applied successfully."
}

# --- Create ML Quick Reference ---
create_ml_reference() {
    print_header "Creating ML Development Reference"
    
    cat > /home/$USERNAME/ML_Quick_Reference.md << 'EOF'
# ROG Flow Z13 - ML Development Quick Reference

## Power Management
```bash
# Set performance mode for training
sudo asusctl profile -P Performance

# Set quiet mode for battery life
sudo asusctl profile -P Quiet
```

## GPU Acceleration (ROCm)
```bash
# Check GPU status
rocm-smi

# Test PyTorch GPU
python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

## Common ML Commands
```bash
# Start Jupyter Lab
jupyter lab

# Install package in user space
pip3 install --user package_name

# Create virtual environment
python3 -m venv ml_env
source ml_env/bin/activate
```

## Useful Directories
- `~/ML_Projects/` - Your ML projects
- `~/Datasets/` - Training data
- `~/Models/` - Saved models
- `~/Notebooks/` - Jupyter notebooks

## Performance Tips for Z13
1. Use Performance mode for training (`asusctl profile -P Performance`)
2. Monitor GPU temperature during long training sessions
3. Use ZFS snapshots before major experiments
4. Keep datasets on fast NVMe storage

Enjoy your ML development on the ROG Flow Z13!
EOF
    
    chown $USERNAME:$USERNAME /home/$USERNAME/ML_Quick_Reference.md
    print_status "ML reference guide created at ~/ML_Quick_Reference.md"
}

# --- Main Installation Flow ---
main_installation() {
    configure_ml_setup
    setup_prerequisites
    setup_python_ml
    setup_deep_learning
    setup_jupyter
    setup_vscode
    setup_docker
    setup_r_stats
    setup_rocm
    apply_z13_ml_optimizations
    create_ml_reference
    
    print_header "ML Development Setup Complete!"
    print_status "Your ROG Flow Z13 is now ready for machine learning development."
    print_status ""
    print_status "Next steps:"
    print_status "1. Reboot system (recommended for ROCm)"
    print_status "2. Run: ~/start_ml_env.sh to start your ML environment"
    print_status "3. Check ~/ML_Quick_Reference.md for usage tips"
    print_status "4. Test GPU with: python3 -c \"import torch; print(torch.cuda.is_available())\""
    print_status ""
    
    read -p "Reboot now? (y/N): " reboot_choice
    [[ $reboot_choice =~ ^[Yy]$ ]] && reboot
}

# --- Main Function ---
main() {
    [[ $EUID -ne 0 ]] && { print_error "This script must be run as root (use sudo)."; exit 1; }
    
    print_header "ROG Flow Z13 - Machine Learning Development Setup"
    echo "This script sets up a complete ML development environment on Ubuntu."
    echo "Prerequisite: Ubuntu 25.10 installed via Install_Ubuntu25.10.sh"
    echo ""
    
    main_installation
}

main "$@"
