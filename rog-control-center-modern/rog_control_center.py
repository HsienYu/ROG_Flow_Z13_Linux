#!/usr/bin/env python3
"""
Modern ROG Control Center for ROG Flow Z13
GTK4 + Adwaita based GUI with comprehensive power management
"""

import gi
import subprocess
import threading
import os
import sys
import time

gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, GLib, Gio, GObject

class AsusctlInterface:
    """Interface to communicate with asusctl daemon"""
    
    @staticmethod
    def run_command(cmd, check_sudo=True):
        """Run asusctl command safely"""
        try:
            if check_sudo:
                # Test if we can run without password
                test_result = subprocess.run(['sudo', '-n', 'asusctl', '--version'], 
                                           capture_output=True, text=True, timeout=5)
                if test_result.returncode != 0:
                    return None, "sudo configuration required"
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            return result.stdout.strip() if result.returncode == 0 else None, result.stderr.strip()
        except subprocess.TimeoutExpired:
            return None, "Command timed out"
        except Exception as e:
            return None, str(e)
    
    @staticmethod
    def get_current_profile():
        """Get current power profile"""
        stdout, stderr = AsusctlInterface.run_command(['asusctl', 'profile', '-p'])
        if stdout:
            # Parse current profile from output
            if 'Performance' in stdout:
                return 'Performance'
            elif 'Balanced' in stdout:
                return 'Balanced'  
            elif 'Quiet' in stdout:
                return 'Quiet'
        return 'Unknown'
    
    @staticmethod
    def set_profile(profile):
        """Set power profile"""
        stdout, stderr = AsusctlInterface.run_command(['sudo', 'asusctl', 'profile', '-P', profile])
        return stdout is not None
    
    @staticmethod
    def get_available_profiles():
        """Get list of available profiles"""
        stdout, stderr = AsusctlInterface.run_command(['asusctl', 'profile', '-l'])
        if stdout:
            profiles = []
            for line in stdout.split('\n'):
                line = line.strip()
                if line in ['Performance', 'Balanced', 'Quiet']:
                    profiles.append(line)
            return profiles if profiles else ['Performance', 'Balanced', 'Quiet']
        return ['Performance', 'Balanced', 'Quiet']
    
    @staticmethod
    def get_keyboard_brightness():
        """Get current keyboard brightness"""
        stdout, stderr = AsusctlInterface.run_command(['asusctl', '-k'])
        if stdout and 'brightness:' in stdout:
            if 'High' in stdout:
                return 'High'
            elif 'Med' in stdout:
                return 'Med'
            elif 'Low' in stdout:
                return 'Low'
            elif 'Off' in stdout:
                return 'Off'
        return 'Unknown'
    
    @staticmethod
    def set_keyboard_brightness(level):
        """Set keyboard brightness level"""
        stdout, stderr = AsusctlInterface.run_command(['sudo', 'asusctl', '-k', level.lower()])
        return stdout is not None
    
    @staticmethod  
    def get_charge_limit():
        """Get current charge limit"""
        stdout, stderr = AsusctlInterface.run_command(['asusctl', '-c'])
        if stdout and '%' in stdout:
            try:
                # Extract percentage from output
                for line in stdout.split('\n'):
                    if '%' in line and 'limit' in line.lower():
                        return int(line.split('%')[0].split()[-1])
            except:
                pass
        return 100
    
    @staticmethod
    def set_charge_limit(limit):
        """Set battery charge limit"""
        stdout, stderr = AsusctlInterface.run_command(['sudo', 'asusctl', '-c', str(limit)])
        return stdout is not None
    
    @staticmethod
    def get_gnome_power_profile():
        """Get current GNOME power profile"""
        try:
            result = subprocess.run(['powerprofilesctl', 'get'], 
                                  capture_output=True, text=True, timeout=5)
            return result.stdout.strip() if result.returncode == 0 else 'balanced'
        except:
            return 'balanced'
    
    @staticmethod
    def set_gnome_power_profile(profile):
        """Set GNOME power profile"""
        try:
            result = subprocess.run(['powerprofilesctl', 'set', profile], 
                                  capture_output=True, text=True, timeout=5)
            return result.returncode == 0
        except:
            return False

class ROGControlWindow(Adw.ApplicationWindow):
    """Main application window"""
    
    def __init__(self, app):
        super().__init__(application=app)
        self.set_title("ROG Control Center")
        self.set_default_size(800, 600)
        
        # Create toast overlay
        self.toast_overlay = Adw.ToastOverlay()
        self.set_content(self.toast_overlay)
        
        # Build UI
        self.build_ui()
        
        # Update initial status
        self.update_all_status()
    
    def build_ui(self):
        """Build the user interface"""
        # Main scroll container
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        
        # Main vertical box
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        main_box.set_margin_top(20)
        main_box.set_margin_bottom(20)
        main_box.set_margin_start(20)
        main_box.set_margin_end(20)
        
        # Header
        header_group = Adw.PreferencesGroup()
        header_group.set_title("🎮 ROG Flow Z13 Control Center")
        header_group.set_description("Comprehensive power and hardware management")
        
        # Status card
        self.status_row = Adw.ActionRow()
        self.status_row.set_title("System Status")
        self.status_subtitle = "Checking..."
        self.status_row.set_subtitle(self.status_subtitle)
        header_group.add(self.status_row)
        
        main_box.append(header_group)
        
        # Power Profile Management Section
        power_group = Adw.PreferencesGroup()
        power_group.set_title("⚡ Power Profile Management")
        power_group.set_description("Control performance modes and power settings")
        
        # ASUSCTL Power Profiles
        asusctl_profile_row = Adw.ComboRow()
        asusctl_profile_row.set_title("ASUSCTL Profile")
        asusctl_profile_row.set_subtitle("Hardware-level power profiles with TDP control")
        
        # Create string list for ASUSCTL profiles
        self.asusctl_profile_model = Gtk.StringList()
        profiles = AsusctlInterface.get_available_profiles()
        for profile in profiles:
            self.asusctl_profile_model.append(profile)
        asusctl_profile_row.set_model(self.asusctl_profile_model)
        
        # Connect signal
        asusctl_profile_row.connect('notify::selected', self.on_asusctl_profile_changed)
        self.asusctl_profile_row = asusctl_profile_row
        power_group.add(asusctl_profile_row)
        
        # GNOME Power Profiles
        gnome_profile_row = Adw.ComboRow()
        gnome_profile_row.set_title("GNOME Profile")
        gnome_profile_row.set_subtitle("System-level power management integration")
        
        # Create string list for GNOME profiles
        self.gnome_profile_model = Gtk.StringList()
        gnome_profiles = ['power-saver', 'balanced', 'performance']
        for profile in gnome_profiles:
            self.gnome_profile_model.append(profile.title())
        gnome_profile_row.set_model(self.gnome_profile_model)
        
        # Connect signal
        gnome_profile_row.connect('notify::selected', self.on_gnome_profile_changed)
        self.gnome_profile_row = gnome_profile_row
        power_group.add(gnome_profile_row)
        
        main_box.append(power_group)
        
        # Keyboard Section
        keyboard_group = Adw.PreferencesGroup()
        keyboard_group.set_title("⌨️ Keyboard Controls")
        keyboard_group.set_description("Manage keyboard backlight settings")
        
        # Keyboard brightness
        kbd_brightness_row = Adw.ComboRow()
        kbd_brightness_row.set_title("Keyboard Backlight")
        kbd_brightness_row.set_subtitle("Adjust keyboard backlight brightness")
        
        # Create string list for brightness
        self.kbd_brightness_model = Gtk.StringList()
        brightness_levels = ['Off', 'Low', 'Med', 'High']
        for level in brightness_levels:
            self.kbd_brightness_model.append(level)
        kbd_brightness_row.set_model(self.kbd_brightness_model)
        
        # Connect signal
        kbd_brightness_row.connect('notify::selected', self.on_keyboard_brightness_changed)
        self.kbd_brightness_row = kbd_brightness_row
        keyboard_group.add(kbd_brightness_row)
        
        main_box.append(keyboard_group)
        
        # Battery Section
        battery_group = Adw.PreferencesGroup()
        battery_group.set_title("🔋 Battery Management")
        battery_group.set_description("Optimize battery health and charging")
        
        # Charge limit slider
        charge_limit_row = Adw.ActionRow()
        charge_limit_row.set_title("Charge Limit")
        charge_limit_row.set_subtitle("Limit charging to extend battery life")
        
        # Charge limit adjustment
        charge_adjustment = Gtk.Adjustment(value=100, lower=20, upper=100, step_increment=5, page_increment=10)
        self.charge_scale = Gtk.Scale(adjustment=charge_adjustment, orientation=Gtk.Orientation.HORIZONTAL)
        self.charge_scale.set_digits(0)
        self.charge_scale.set_hexpand(True)
        self.charge_scale.set_draw_value(True)
        self.charge_scale.set_value_pos(Gtk.PositionType.RIGHT)
        self.charge_scale.connect('value-changed', self.on_charge_limit_changed)
        
        # Add marks for common values
        for value in [80, 85, 90, 100]:
            self.charge_scale.add_mark(value, Gtk.PositionType.BOTTOM, f"{value}%")
        
        charge_limit_row.add_suffix(self.charge_scale)
        battery_group.add(charge_limit_row)
        
        # Quick charge limit buttons
        charge_buttons_row = Adw.ActionRow()
        charge_buttons_row.set_title("Quick Settings")
        charge_buttons_row.set_subtitle("Common charge limit presets")
        
        # Create button box
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        
        for limit in [80, 85, 90, 100]:
            btn = Gtk.Button(label=f"{limit}%")
            btn.add_css_class("pill")
            btn.connect('clicked', lambda b, l=limit: self.set_charge_limit_quick(l))
            button_box.append(btn)
        
        charge_buttons_row.add_suffix(button_box)
        battery_group.add(charge_buttons_row)
        
        main_box.append(battery_group)
        
        # System Information Section
        info_group = Adw.PreferencesGroup()
        info_group.set_title("ℹ️ System Information")
        info_group.set_description("Hardware and software details")
        
        # System info row
        self.system_info_row = Adw.ExpanderRow()
        self.system_info_row.set_title("Hardware Information")
        self.system_info_row.set_subtitle("Click to expand system details")
        
        # Add system info content
        info_content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        info_content.set_margin_top(10)
        info_content.set_margin_bottom(10)
        info_content.set_margin_start(15)
        info_content.set_margin_end(15)
        
        info_labels = [
            ("Model", "ROG Flow Z13 (GZ302EA)"),
            ("ASUSCTL Version", "Loading..."),
            ("Power Profiles Daemon", "Loading..."),
            ("Screen Brightness", "F7/F8 keys (Ubuntu native)"),
        ]
        
        for title, value in info_labels:
            info_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
            title_label = Gtk.Label(label=title)
            title_label.set_xalign(0)
            title_label.add_css_class("caption-heading")
            value_label = Gtk.Label(label=value)
            value_label.set_xalign(1)
            value_label.set_hexpand(True)
            info_row.append(title_label)
            info_row.append(value_label)
            info_content.append(info_row)
        
        self.system_info_row.add_row(info_content)
        info_group.add(self.system_info_row)
        
        main_box.append(info_group)
        
        # Tips Section
        tips_group = Adw.PreferencesGroup()
        tips_group.set_title("💡 Tips & Recommendations")
        
        tips_content = [
            ("🔆 Brightness Keys", "Use F7/F8 to control screen brightness (Ubuntu native drivers)"),
            ("🔋 Battery Health", "Set charge limit to 80-85% for daily use to extend battery life"),
            ("⚡ Performance Mode", "Use for gaming, rendering, or intensive tasks (~120W TDP)"),
            ("🔕 Quiet Mode", "Use for reading, writing, or presentations (minimal fan noise)"),
            ("⚖️ Balanced Mode", "Best for general computing with good battery life (~70W TDP)"),
        ]
        
        for title, description in tips_content:
            tip_row = Adw.ActionRow()
            tip_row.set_title(title)
            tip_row.set_subtitle(description)
            tips_group.add(tip_row)
        
        main_box.append(tips_group)
        
        # Add to scrolled window
        scrolled.set_child(main_box)
        self.toast_overlay.set_child(scrolled)
    
    def show_toast(self, message, timeout=3):
        """Show toast notification"""
        toast = Adw.Toast(title=message, timeout=timeout)
        self.toast_overlay.add_toast(toast)
    
    def update_all_status(self):
        """Update all status information in background"""
        def update_in_background():
            try:
                # Get current values
                asusctl_profile = AsusctlInterface.get_current_profile()
                gnome_profile = AsusctlInterface.get_gnome_power_profile()
                kbd_brightness = AsusctlInterface.get_keyboard_brightness()
                charge_limit = AsusctlInterface.get_charge_limit()
                
                # Update UI in main thread
                GLib.idle_add(lambda: self.update_ui_status(asusctl_profile, gnome_profile, kbd_brightness, charge_limit))
            except Exception as e:
                GLib.idle_add(lambda: self.show_toast(f"Status update error: {str(e)}"))
        
        thread = threading.Thread(target=update_in_background, daemon=True)
        thread.start()
    
    def update_ui_status(self, asusctl_profile, gnome_profile, kbd_brightness, charge_limit):
        """Update UI elements with current status"""
        # Update status row
        self.status_row.set_subtitle(f"ASUSCTL: {asusctl_profile} | GNOME: {gnome_profile.title()} | Keyboard: {kbd_brightness} | Charge: {charge_limit}%")
        
        # Update ASUSCTL profile dropdown
        profiles = AsusctlInterface.get_available_profiles()
        if asusctl_profile in profiles:
            self.asusctl_profile_row.set_selected(profiles.index(asusctl_profile))
        
        # Update GNOME profile dropdown
        gnome_profiles = ['power-saver', 'balanced', 'performance']
        if gnome_profile in gnome_profiles:
            self.gnome_profile_row.set_selected(gnome_profiles.index(gnome_profile))
        
        # Update keyboard brightness dropdown
        brightness_levels = ['Off', 'Low', 'Med', 'High']
        if kbd_brightness in brightness_levels:
            self.kbd_brightness_row.set_selected(brightness_levels.index(kbd_brightness))
        
        # Update charge limit scale
        self.charge_scale.set_value(charge_limit)
        
        return False
    
    def on_asusctl_profile_changed(self, combo_row, pspec):
        """Handle ASUSCTL profile change"""
        selected = combo_row.get_selected()
        if selected != Gtk.INVALID_LIST_POSITION:
            profile = combo_row.get_model().get_string(selected)
            
            def change_profile():
                success = AsusctlInterface.set_profile(profile)
                GLib.idle_add(lambda: self.show_toast(
                    f"✅ Switched to {profile} profile" if success 
                    else f"❌ Failed to switch to {profile} profile"
                ))
                if success:
                    time.sleep(1)
                    GLib.idle_add(self.update_all_status)
            
            thread = threading.Thread(target=change_profile, daemon=True)
            thread.start()
    
    def on_gnome_profile_changed(self, combo_row, pspec):
        """Handle GNOME profile change"""
        selected = combo_row.get_selected()
        if selected != Gtk.INVALID_LIST_POSITION:
            profile_display = combo_row.get_model().get_string(selected)
            profile = profile_display.lower()
            if profile == 'power saver':
                profile = 'power-saver'
            
            def change_profile():
                success = AsusctlInterface.set_gnome_power_profile(profile)
                GLib.idle_add(lambda: self.show_toast(
                    f"✅ Switched to {profile_display} power mode" if success 
                    else f"❌ Failed to switch to {profile_display} power mode"
                ))
            
            thread = threading.Thread(target=change_profile, daemon=True)
            thread.start()
    
    def on_keyboard_brightness_changed(self, combo_row, pspec):
        """Handle keyboard brightness change"""
        selected = combo_row.get_selected()
        if selected != Gtk.INVALID_LIST_POSITION:
            brightness = combo_row.get_model().get_string(selected)
            
            def change_brightness():
                success = AsusctlInterface.set_keyboard_brightness(brightness)
                GLib.idle_add(lambda: self.show_toast(
                    f"✅ Keyboard backlight: {brightness}" if success 
                    else f"❌ Failed to set keyboard backlight"
                ))
            
            thread = threading.Thread(target=change_brightness, daemon=True)
            thread.start()
    
    def on_charge_limit_changed(self, scale):
        """Handle charge limit change"""
        limit = int(scale.get_value())
        
        def change_limit():
            success = AsusctlInterface.set_charge_limit(limit)
            GLib.idle_add(lambda: self.show_toast(
                f"✅ Charge limit: {limit}%" if success 
                else f"❌ Failed to set charge limit"
            ))
        
        thread = threading.Thread(target=change_limit, daemon=True)
        thread.start()
    
    def set_charge_limit_quick(self, limit):
        """Set charge limit using quick buttons"""
        self.charge_scale.set_value(limit)

class ROGControlApp(Adw.Application):
    """Main application"""
    
    def __init__(self):
        super().__init__(application_id='org.rog.ControlCenter')
        self.connect('activate', self.on_activate)
    
    def on_activate(self, app):
        """Application activation"""
        self.window = ROGControlWindow(self)
        self.window.present()

def main():
    """Main entry point"""
    # Check if we're running with proper environment
    if 'DISPLAY' not in os.environ and 'WAYLAND_DISPLAY' not in os.environ:
        print("❌ No display server detected. Please run in a graphical environment.")
        sys.exit(1)
    
    # Create and run application
    app = ROGControlApp()
    return app.run(sys.argv)

if __name__ == '__main__':
    exit(main())
