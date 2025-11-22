#!/usr/bin/env python3
"""
ROG Flow Z13 Keyboard RGB Control GUI
Simple GUI for controlling keyboard backlight colors
"""

import hid
import sys
import time
from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                              QHBoxLayout, QPushButton, QLabel, QSlider, 
                              QComboBox, QColorDialog, QMessageBox)
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
    
    def set_breathe_mode(self, r, g, b, speed=0xeb):
        """Set breathing effect"""
        packet = [
            0x5d, 0xb4, 0x00, 0x00,
            r, g, b,
            speed, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        ]
        packet += [0x00] * (64 - len(packet))
        return self.send_packet(packet)
    
    def set_pulse_mode(self, r, g, b, speed=0xeb):
        """Set pulse effect"""
        packet = [
            0x5d, 0xbc, 0x00, 0x00,
            r, g, b,
            speed, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        ]
        packet += [0x00] * (64 - len(packet))
        return self.send_packet(packet)
    
    def set_rainbow_mode(self, speed=0xeb):
        """Set rainbow cycle mode"""
        packet = [
            0x5d, 0xb5, 0x00, 0x00,
            0x00, 0x00, 0x00,
            speed, 0x00, 0x00,
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
        self.setWindowTitle("ROG Flow Z13 Keyboard RGB Control")
        self.setFixedSize(400, 500)
        
        # Main widget and layout
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        layout = QVBoxLayout()
        main_widget.setLayout(layout)
        
        # Color display
        self.color_label = QLabel()
        self.color_label.setFixedHeight(80)
        self.color_label.setStyleSheet(f"background-color: {self.current_color.name()}; border: 2px solid black;")
        layout.addWidget(self.color_label)
        
        # RGB sliders
        layout.addWidget(QLabel("Red:"))
        self.red_slider = self.create_slider()
        self.red_slider.setValue(255)
        self.red_value_label = QLabel("255")
        slider_layout = QHBoxLayout()
        slider_layout.addWidget(self.red_slider)
        slider_layout.addWidget(self.red_value_label)
        layout.addLayout(slider_layout)
        
        layout.addWidget(QLabel("Green:"))
        self.green_slider = self.create_slider()
        self.green_slider.setValue(255)
        self.green_value_label = QLabel("255")
        slider_layout = QHBoxLayout()
        slider_layout.addWidget(self.green_slider)
        slider_layout.addWidget(self.green_value_label)
        layout.addLayout(slider_layout)
        
        layout.addWidget(QLabel("Blue:"))
        self.blue_slider = self.create_slider()
        self.blue_slider.setValue(255)
        self.blue_value_label = QLabel("255")
        slider_layout = QHBoxLayout()
        slider_layout.addWidget(self.blue_slider)
        slider_layout.addWidget(self.blue_value_label)
        layout.addLayout(slider_layout)
        
        # Connect sliders
        self.red_slider.valueChanged.connect(self.update_color)
        self.green_slider.valueChanged.connect(self.update_color)
        self.blue_slider.valueChanged.connect(self.update_color)
        
        # Color picker button
        color_picker_btn = QPushButton("Choose Color")
        color_picker_btn.clicked.connect(self.choose_color)
        layout.addWidget(color_picker_btn)
        
        # Mode selection
        layout.addWidget(QLabel("Effect Mode:"))
        self.mode_combo = QComboBox()
        self.mode_combo.addItems(["Static", "Breathe", "Pulse", "Rainbow"])
        layout.addWidget(self.mode_combo)
        
        # Speed slider (for effects)
        layout.addWidget(QLabel("Effect Speed:"))
        self.speed_slider = QSlider(Qt.Orientation.Horizontal)
        self.speed_slider.setMinimum(0)
        self.speed_slider.setMaximum(255)
        self.speed_slider.setValue(235)  # 0xeb
        self.speed_value_label = QLabel("Medium")
        slider_layout = QHBoxLayout()
        slider_layout.addWidget(self.speed_slider)
        slider_layout.addWidget(self.speed_value_label)
        layout.addLayout(slider_layout)
        self.speed_slider.valueChanged.connect(self.update_speed_label)
        
        # Apply button
        apply_btn = QPushButton("Apply")
        apply_btn.setStyleSheet("background-color: #4CAF50; color: white; font-weight: bold; padding: 10px;")
        apply_btn.clicked.connect(self.apply_settings)
        layout.addWidget(apply_btn)
        
        # Quick color buttons
        layout.addWidget(QLabel("Quick Colors:"))
        quick_colors_layout = QHBoxLayout()
        colors = [
            ("Red", "#FF0000"),
            ("Green", "#00FF00"),
            ("Blue", "#0000FF"),
            ("Purple", "#FF00FF"),
            ("Cyan", "#00FFFF"),
            ("Yellow", "#FFFF00"),
            ("White", "#FFFFFF"),
        ]
        for name, color_hex in colors:
            btn = QPushButton()
            btn.setFixedSize(40, 40)
            btn.setStyleSheet(f"background-color: {color_hex}; border: 1px solid black;")
            btn.clicked.connect(lambda checked, c=color_hex: self.set_quick_color(c))
            quick_colors_layout.addWidget(btn)
        layout.addLayout(quick_colors_layout)
        
        layout.addStretch()
    
    def create_slider(self):
        slider = QSlider(Qt.Orientation.Horizontal)
        slider.setMinimum(0)
        slider.setMaximum(255)
        return slider
    
    def update_color(self):
        r = self.red_slider.value()
        g = self.green_slider.value()
        b = self.blue_slider.value()
        
        self.red_value_label.setText(str(r))
        self.green_value_label.setText(str(g))
        self.blue_value_label.setText(str(b))
        
        self.current_color = QColor(r, g, b)
        self.color_label.setStyleSheet(f"background-color: {self.current_color.name()}; border: 2px solid black;")
    
    def update_speed_label(self):
        speed = self.speed_slider.value()
        if speed < 85:
            label = "Slow"
        elif speed < 170:
            label = "Medium"
        else:
            label = "Fast"
        self.speed_value_label.setText(label)
    
    def choose_color(self):
        color = QColorDialog.getColor(self.current_color, self)
        if color.isValid():
            self.current_color = color
            self.red_slider.setValue(color.red())
            self.green_slider.setValue(color.green())
            self.blue_slider.setValue(color.blue())
    
    def set_quick_color(self, color_hex):
        color = QColor(color_hex)
        self.red_slider.setValue(color.red())
        self.green_slider.setValue(color.green())
        self.blue_slider.setValue(color.blue())
        self.apply_settings()
    
    def apply_settings(self):
        r = self.red_slider.value()
        g = self.green_slider.value()
        b = self.blue_slider.value()
        speed = self.speed_slider.value()
        mode = self.mode_combo.currentText()
        
        success = False
        if mode == "Static":
            success = self.controller.set_static_color(r, g, b)
        elif mode == "Breathe":
            success = self.controller.set_breathe_mode(r, g, b, speed)
        elif mode == "Pulse":
            success = self.controller.set_pulse_mode(r, g, b, speed)
        elif mode == "Rainbow":
            success = self.controller.set_rainbow_mode(speed)
        
        if not success:
            QMessageBox.warning(self, "Error", "Failed to apply settings. Make sure you're running with sudo.")
    
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
        msg.setInformativeText("Please run this application with sudo:\nsudo python3 keyboard_rgb_control.py")
        msg.setWindowTitle("Permission Error")
        msg.exec()
        sys.exit(1)
    
    window = MainWindow()
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
