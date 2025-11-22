#!/usr/bin/env python3
"""
ROG Flow Z13 Keyboard RGB Control - Simple Static Mode
Simplified GUI for static keyboard backlight colors only
"""

import hid
import sys
import time
from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                              QHBoxLayout, QPushButton, QLabel, QSlider, 
                              QColorDialog, QMessageBox)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QColor

# Device IDs
VENDOR_ID = 0x0B05
PRODUCT_ID = 0x1A30

class KeyboardController:
    def __init__(self):
        self.device = None
        self.connect()
    
    def connect(self):
        """Connect to the keyboard device"""
        try:
            self.device = hid.device()
            self.device.open(VENDOR_ID, PRODUCT_ID)
            return True
        except Exception as e:
            print(f"Error connecting to device: {e}")
            return False
    
    def send_packet(self, packet):
        """Send a HID packet to the device"""
        try:
            if self.device:
                full_packet = [0x00] + packet
                self.device.write(full_packet)
                time.sleep(0.05)
                return True
        except Exception as e:
            print(f"Error sending packet: {e}")
            return False
        return False
    
    def set_static_color(self, r, g, b):
        """Set static color mode"""
        packet = [
            0x5d, 0xb3, 0x00, 0x00,
            r, g, b,
            0xeb, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        ]
        packet += [0x00] * (64 - len(packet))
        return self.send_packet(packet)
    
    def close(self):
        """Close device connection"""
        if self.device:
            self.device.close()

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.controller = KeyboardController()
        self.current_color = QColor(255, 255, 255)
        self.init_ui()
    
    def init_ui(self):
        self.setWindowTitle("ROG Flow Z13 RGB Control")
        self.setFixedSize(400, 400)
        
        # Main widget and layout
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        layout = QVBoxLayout()
        main_widget.setLayout(layout)
        
        # Title
        title = QLabel("Keyboard RGB Control")
        title.setStyleSheet("font-size: 18px; font-weight: bold; padding: 10px;")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title)
        
        # Color display
        self.color_label = QLabel()
        self.color_label.setFixedHeight(100)
        self.color_label.setStyleSheet(f"background-color: {self.current_color.name()}; border: 2px solid black; border-radius: 5px;")
        layout.addWidget(self.color_label)
        
        # RGB sliders
        layout.addWidget(QLabel("Red:"))
        self.red_slider = self.create_slider()
        self.red_slider.setValue(255)
        self.red_value_label = QLabel("255")
        self.red_value_label.setFixedWidth(40)
        self.red_value_label.setAlignment(Qt.AlignmentFlag.AlignRight)
        slider_layout = QHBoxLayout()
        slider_layout.addWidget(self.red_slider)
        slider_layout.addWidget(self.red_value_label)
        layout.addLayout(slider_layout)
        
        layout.addWidget(QLabel("Green:"))
        self.green_slider = self.create_slider()
        self.green_slider.setValue(255)
        self.green_value_label = QLabel("255")
        self.green_value_label.setFixedWidth(40)
        self.green_value_label.setAlignment(Qt.AlignmentFlag.AlignRight)
        slider_layout = QHBoxLayout()
        slider_layout.addWidget(self.green_slider)
        slider_layout.addWidget(self.green_value_label)
        layout.addLayout(slider_layout)
        
        layout.addWidget(QLabel("Blue:"))
        self.blue_slider = self.create_slider()
        self.blue_slider.setValue(255)
        self.blue_value_label = QLabel("255")
        self.blue_value_label.setFixedWidth(40)
        self.blue_value_label.setAlignment(Qt.AlignmentFlag.AlignRight)
        slider_layout = QHBoxLayout()
        slider_layout.addWidget(self.blue_slider)
        slider_layout.addWidget(self.blue_value_label)
        layout.addLayout(slider_layout)
        
        # Connect sliders to update color preview and apply immediately
        self.red_slider.valueChanged.connect(self.slider_changed)
        self.green_slider.valueChanged.connect(self.slider_changed)
        self.blue_slider.valueChanged.connect(self.slider_changed)
        
        # Color picker button
        color_picker_btn = QPushButton("🎨 Choose Color")
        color_picker_btn.setStyleSheet("padding: 8px; font-size: 14px;")
        color_picker_btn.clicked.connect(self.choose_color)
        layout.addWidget(color_picker_btn)
        
        # Quick color buttons
        layout.addWidget(QLabel("Quick Colors:"))
        quick_colors_layout = QHBoxLayout()
        colors = [
            ("Red", "#FF0000"),
            ("Orange", "#FF8000"),
            ("Yellow", "#FFFF00"),
            ("Green", "#00FF00"),
            ("Cyan", "#00FFFF"),
            ("Blue", "#0000FF"),
            ("Purple", "#FF00FF"),
            ("White", "#FFFFFF"),
        ]
        for name, color_hex in colors:
            btn = QPushButton()
            btn.setFixedSize(45, 45)
            btn.setStyleSheet(f"background-color: {color_hex}; border: 2px solid #333; border-radius: 5px;")
            btn.setToolTip(name)
            btn.clicked.connect(lambda checked, c=color_hex: self.set_quick_color(c))
            quick_colors_layout.addWidget(btn)
        layout.addLayout(quick_colors_layout)
        
        layout.addStretch()
        
        # Set initial color
        self.apply_color()
    
    def create_slider(self):
        slider = QSlider(Qt.Orientation.Horizontal)
        slider.setMinimum(0)
        slider.setMaximum(255)
        return slider
    
    def slider_changed(self):
        r = self.red_slider.value()
        g = self.green_slider.value()
        b = self.blue_slider.value()
        
        self.red_value_label.setText(str(r))
        self.green_value_label.setText(str(g))
        self.blue_value_label.setText(str(b))
        
        self.current_color = QColor(r, g, b)
        self.color_label.setStyleSheet(f"background-color: {self.current_color.name()}; border: 2px solid black; border-radius: 5px;")
        
        # Apply color immediately
        self.apply_color()
    
    def choose_color(self):
        color = QColorDialog.getColor(self.current_color, self)
        if color.isValid():
            self.current_color = color
            self.red_slider.setValue(color.red())
            self.green_slider.setValue(color.green())
            self.blue_slider.setValue(color.blue())
            # Color is applied automatically by slider_changed
    
    def set_quick_color(self, color_hex):
        color = QColor(color_hex)
        self.red_slider.setValue(color.red())
        self.green_slider.setValue(color.green())
        self.blue_slider.setValue(color.blue())
        # Color is applied automatically by slider_changed
    
    def apply_color(self):
        r = self.red_slider.value()
        g = self.green_slider.value()
        b = self.blue_slider.value()
        
        success = self.controller.set_static_color(r, g, b)
        if not success:
            print("Failed to apply color")
    
    def closeEvent(self, event):
        self.controller.close()
        event.accept()

def main():
    app = QApplication(sys.argv)
    
    # Check if running as root
    import os
    if os.geteuid() != 0:
        msg = QMessageBox()
        msg.setIcon(QMessageBox.Icon.Warning)
        msg.setText("Root privileges required")
        msg.setInformativeText("Please run this application with sudo:\nsudo python3 keyboard_rgb_simple.py")
        msg.setWindowTitle("Permission Error")
        msg.exec()
        sys.exit(1)
    
    window = MainWindow()
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
