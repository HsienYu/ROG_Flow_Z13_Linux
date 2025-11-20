#!/usr/bin/env python3
"""
AsusCtrl GUI - A graphical control interface for asusctl
"""

import gi
import subprocess
import os

gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, GLib

class AsusCtrlWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.set_title("AsusCtrl Control Panel")
        self.set_default_size(600, 700)
        
        # Main box
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.set_child(main_box)
        
        # Header bar
        header = Gtk.HeaderBar()
        self.set_titlebar(header)
        
        # Scrolled window
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        main_box.append(scrolled)
        
        # Content box with padding
        content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        content_box.set_margin_start(20)
        content_box.set_margin_end(20)
        content_box.set_margin_top(20)
        content_box.set_margin_bottom(20)
        scrolled.set_child(content_box)
        
        # Profile Section
        content_box.append(self.create_profile_section())
        content_box.append(Gtk.Separator())
        
        # Keyboard Brightness Section
        content_box.append(self.create_keyboard_brightness_section())
        content_box.append(Gtk.Separator())
        
        # Battery Charge Limit Section
        content_box.append(self.create_battery_section())
        content_box.append(Gtk.Separator())
        
        # Keyboard Lighting Section
        content_box.append(self.create_aura_section())
        content_box.append(Gtk.Separator())
        
        # Status bar
        self.status_label = Gtk.Label(label="Ready")
        self.status_label.set_margin_top(10)
        self.status_label.set_margin_bottom(10)
        self.status_label.add_css_class("dim-label")
        main_box.append(self.status_label)
        
    def create_profile_section(self):
        """Create the performance profile section"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        
        label = Gtk.Label(label="Performance Profile")
        label.set_halign(Gtk.Align.START)
        label.add_css_class("title-3")
        box.append(label)
        
        profile_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        profile_box.set_homogeneous(True)
        
        profiles = ["Quiet", "Balanced", "Performance"]
        for profile in profiles:
            btn = Gtk.Button(label=profile)
            btn.connect("clicked", self.on_profile_clicked, profile.lower())
            profile_box.append(btn)
        
        box.append(profile_box)
        return box
    
    def create_keyboard_brightness_section(self):
        """Create keyboard brightness control section"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        
        label = Gtk.Label(label="Keyboard Brightness")
        label.set_halign(Gtk.Align.START)
        label.add_css_class("title-3")
        box.append(label)
        
        brightness_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        brightness_box.set_homogeneous(True)
        
        levels = ["Off", "Low", "Med", "High"]
        for level in levels:
            btn = Gtk.Button(label=level)
            btn.connect("clicked", self.on_kbd_brightness_clicked, level.lower())
            brightness_box.append(btn)
        
        box.append(brightness_box)
        
        # Toggle buttons
        toggle_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        toggle_box.set_halign(Gtk.Align.CENTER)
        toggle_box.set_margin_top(5)
        
        prev_btn = Gtk.Button(label="← Previous")
        prev_btn.connect("clicked", self.on_prev_kbd_brightness)
        toggle_box.append(prev_btn)
        
        next_btn = Gtk.Button(label="Next →")
        next_btn.connect("clicked", self.on_next_kbd_brightness)
        toggle_box.append(next_btn)
        
        box.append(toggle_box)
        return box
    
    def create_battery_section(self):
        """Create battery charge limit section"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        
        label = Gtk.Label(label="Battery Management")
        label.set_halign(Gtk.Align.START)
        label.add_css_class("title-3")
        box.append(label)
        
        # Charge limit control
        limit_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        limit_box.set_halign(Gtk.Align.CENTER)
        
        limit_label = Gtk.Label(label="Charge Limit:")
        limit_box.append(limit_label)
        
        self.charge_limit_spin = Gtk.SpinButton()
        self.charge_limit_spin.set_range(20, 100)
        self.charge_limit_spin.set_increments(1, 10)
        self.charge_limit_spin.set_value(80)
        limit_box.append(self.charge_limit_spin)
        
        set_limit_btn = Gtk.Button(label="Set Limit")
        set_limit_btn.connect("clicked", self.on_set_charge_limit)
        limit_box.append(set_limit_btn)
        
        box.append(limit_box)
        
        # One-shot charge button
        oneshot_btn = Gtk.Button(label="Enable One-Shot 100% Charge")
        oneshot_btn.connect("clicked", self.on_oneshot_charge)
        oneshot_btn.set_margin_top(5)
        box.append(oneshot_btn)
        
        return box
    
    def create_aura_section(self):
        """Create keyboard lighting (Aura) section"""
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        
        label = Gtk.Label(label="Keyboard Lighting (Aura)")
        label.set_halign(Gtk.Align.START)
        label.add_css_class("title-3")
        box.append(label)
        
        # Mode toggle buttons
        mode_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        mode_box.set_halign(Gtk.Align.CENTER)
        
        prev_mode_btn = Gtk.Button(label="← Previous Mode")
        prev_mode_btn.connect("clicked", self.on_prev_aura_mode)
        mode_box.append(prev_mode_btn)
        
        next_mode_btn = Gtk.Button(label="Next Mode →")
        next_mode_btn.connect("clicked", self.on_next_aura_mode)
        mode_box.append(next_mode_btn)
        
        box.append(mode_box)
        
        # Static color section
        static_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        static_box.set_halign(Gtk.Align.CENTER)
        static_box.set_margin_top(10)
        
        static_label = Gtk.Label(label="Static Color:")
        static_box.append(static_label)
        
        self.color_button = Gtk.ColorButton()
        static_box.append(self.color_button)
        
        set_color_btn = Gtk.Button(label="Set Color")
        set_color_btn.connect("clicked", self.on_set_static_color)
        static_box.append(set_color_btn)
        
        box.append(static_box)
        return box
    
    # Callback functions
    def on_profile_clicked(self, button, profile):
        self.run_command(["asusctl", "profile", "-P", profile])
    
    def on_kbd_brightness_clicked(self, button, level):
        self.run_command(["asusctl", "-k", level])
    
    def on_prev_kbd_brightness(self, button):
        self.run_command(["asusctl", "-p"])
    
    def on_next_kbd_brightness(self, button):
        self.run_command(["asusctl", "-n"])
    
    def on_set_charge_limit(self, button):
        limit = int(self.charge_limit_spin.get_value())
        self.run_command(["asusctl", "-c", str(limit)])
    
    def on_oneshot_charge(self, button):
        self.run_command(["asusctl", "-o"])
    
    def on_prev_aura_mode(self, button):
        self.run_command(["asusctl", "aura", "-p"])
    
    def on_next_aura_mode(self, button):
        self.run_command(["asusctl", "aura", "-n"])
    
    def on_set_static_color(self, button):
        color = self.color_button.get_rgba()
        r = int(color.red * 255)
        g = int(color.green * 255)
        b = int(color.blue * 255)
        self.run_command(["asusctl", "aura", "static", "-c", f"{r:02x}{g:02x}{b:02x}"])
    
    def run_command(self, cmd):
        """Execute asusctl command and update status"""
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            self.update_status(f"✓ Command executed: {' '.join(cmd[1:])}")
        except subprocess.CalledProcessError as e:
            self.update_status(f"✗ Error: {e.stderr.strip()}")
        except Exception as e:
            self.update_status(f"✗ Error: {str(e)}")
    
    def update_status(self, message):
        """Update the status bar message"""
        self.status_label.set_text(message)
        # Clear status after 3 seconds
        GLib.timeout_add_seconds(3, lambda: self.status_label.set_text("Ready"))


class AsusCtrlApp(Adw.Application):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.connect('activate', self.on_activate)
    
    def on_activate(self, app):
        self.win = AsusCtrlWindow(application=app)
        self.win.present()


def main():
    app = AsusCtrlApp(application_id="com.github.asusctrl_gui")
    return app.run(None)


if __name__ == '__main__':
    main()
