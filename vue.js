document.addEventListener('DOMContentLoaded', function () {
    app = new Vue({
        el: '#app',
        data: {
            ui: false,
            currentTime: '12:00',
            batteryLevel: 85,
            batteryCharging: false,
            currentApp: null,
            openSubSettings: null,
            cmdInput: '',
            // Lock screen variables
            isLocked: true,
            lockScreenAnimation: false,
            fingerprintSuccess: false,
            fingerprintError: false,
            fingerprintScanning: false,
            fingerprintAttempts: 0,
            terminalOutput: [],
            hackProgress: 0,
            isHacking: false,
            currentHackType: null,
            activeHackMethod: null,
            activeCameraMethod: false,
            activeTrackMethod: false,
            activePhoneMethod: false,
            activeBankMethod: false,
            activeSystemMethod: false,
            activeBruteMethod: false,
            activeDdosMethod: false,

            // Araç kontrol değişkenleri
            activeVehicleMethod: false,
            selectedVehicle: null,
            showVehicleControls: false,
            vehicleLocked: true,
            engineRunning: false,
            doorStates: {
                driver: false,
                passenger: false,
                hood: false,
                trunk: false
            },
            gpsInterval: null, // GPS takibi için interval

            // Phone settings
            phoneSettings: {
                wallpaper: 'https://i.imgur.com/SyvMlBc.jpg',
                frameColor: '#1A1A1A',
                terminalColor: '#00FF00',
                terminalFont: 'monospace',
                textColor: '#FFFFFF'
            },

            // Background options
            wallpapers: [],

            // Frame color options
            frameColors: [
                '#F5F5F5', // Very light gray
                '#E0E0E0', // Light gray
                '#D1E8E2', // Pastel green
                '#A0C4FF', // Pastel blue
                '#FFABAB', // Pastel red
                '#FFC3A0', // Pastel orange
                '#FF677D', // Pastel pink
                '#D9BF77', // Pastel yellow
                '#C3B8E0', // Pastel purple
                '#B9FBC0', // Mint green
                '#FFE156', // Pastel gold
                '#A3D8D4'  // Pale turquoise
            ],

            // Terminal color options
            terminalColors: [
                '#00FF00', '#00FFFF', '#FF00FF', '#FFFFFF',
                '#FF0000', '#0000FF', '#FFFF00', '#39FF14',
                '#04D9FF', '#FF073A', '#00FF9D', '#FF00FF'
            ],

            // Text color options
            textColors: [
                '#FFFFFF', '#00FF00', '#00FFFF', '#FF00FF',
                '#FF0000', '#0000FF', '#FFFF00', '#39FF14',
                '#04D9FF', '#FF073A', '#00FF9D', '#FF00FF'
            ],

            vpnActive: false,
            selectedVpnServer: 0,
            vpnConnectionTime: 0,
            vpnDataUsage: 0,
            vpnTimer: null,
            vpnDataInterval: null,
            vpnServers: [
                { name: 'Turkey VPN', location: 'Turkey', icon: 'ri-flag-2-fill', color: '#E30A17' },
                { name: 'Germany VPN', location: 'Germany', icon: 'ri-flag-2-fill', color: '#000000' },
                { name: 'USA VPN', location: 'USA', icon: 'ri-flag-2-fill', color: '#B22234' },
                { name: 'UK VPN', location: 'UK', icon: 'ri-flag-2-fill', color: '#012169' },
                { name: 'Canada VPN', location: 'Canada', icon: 'ri-flag-2-fill', color: '#FF0000' },
                { name: 'Australia VPN', location: 'Australia', icon: 'ri-flag-2-fill', color: '#00008B' }
            ],
            wallet: 5000,
            cart: [],
            showCart: false,
            marketProducts: [],
            selectedCategory: 'all',
            filteredProducts: [],
            categories: [],
            // Apps list
            apps: [
                { id: 'terminal', name: 'Terminal', icon: 'ri-terminal-box-fill', color: '#4CAF50', action: 'openTerminal' },
                { id: 'vpn', name: 'SecureVPN', icon: 'ri-shield-check-fill', color: '#2196F3', action: 'openVPN' },
                { id: 'market', name: 'Black Market', icon: 'ri-shopping-bag-fill', color: '#FF4757', description: 'Special products' },
                { id: 'settings', name: 'Settings', icon: 'ri-settings-fill', color: '#A55EEA', description: 'System settings' },
                { id: 'hack', name: 'Hack Tools', icon: 'ri-code-box-fill', color: '#FFA502', description: 'Advanced hacking tools' }
            ],

            // Settings tabs
            settingsTabs: [
                { id: 'appearance', name: 'Appearance', icon: 'ri-palette-fill', color: '#FF6B6B' },
                { id: 'security', name: 'Security', icon: 'ri-shield-fill', color: '#2ED573' },
                { id: 'sound', name: 'Sound', icon: 'ri-volume-up-fill', color: '#1E90FF' },
                { id: 'language', name: 'Language', icon: 'ri-translate-2', color: '#A55EEA' }
            ],
            activeSettingsTab: 'appearance',
            previousApp: null,
            customColor: '#00FF00',
            rgbValues: {
                r: 0,
                g: 255,
                b: 0
            },
            customWallpaperUrl: '',
            defaultPhoneSettings: {
                wallpaper: 'https://i.imgur.com/SyvMlBc.jpg',
                frameColor: '#1A1A1A',
                terminalColor: '#00FF00',
                terminalFont: 'monospace',
                textColor: '#FFFFFF'
            },
            products: [
                {
                    id: 1,
                    name: "Pistol MK II",
                    description: "Powerful and reliable handgun.",
                    price: 1500,
                    category: "weapons",
                    image: "./assets/img/products/deagle.jpg"
                }
            ],
            currentLanguage: 'en',
            languages: [
                { code: 'en', name: 'English' },
                { code: 'tr', name: 'Türkçe' },
                { code: 'de', name: 'Deutsch' }
            ],
            translations: {},
            nearbyVehicles: [], 
            nearestATM: null,
            atmCheckInterval: null, 
            estimatedLoot: 0, 
            nearbyATMs: [], 
            isHackingATM: false, 
            robbedATMs: {}, 
            lastVehicleLocation: null, 
            showMarkOnMapButton: false, 
            activeATMMethod: false,
            atmHackProgress: 0,
            currentATM: null,
            showDoorControls: false,
            markedLocation: null, 
            markedVehicle: null, 
            transferAmount: 0,
            remainingLoot: 0,
            showCustomWallpaperModal: false,
            currentWallpaper: '',
            defaultWallpaper: 'https://9to5mac.com/wp-content/uploads/sites/6/2024/09/iPhone-16-and-16-Pro-wallpapers-8.jpg?quality=82&strip=all',
        },

        computed: {
            cartTotal() {
                return this.cart.reduce((total, item) => total + (item.price * item.quantity), 0);
            },

            // Get translation for current language
            t() {
                return (key) => {
                    const keys = key.split('.');
                    let result = this.translations[this.currentLanguage];

                    for (const k of keys) {
                        if (result && result[k]) {
                            result = result[k];
                        } else {
                            return key; // Return key if translation not found
                        }
                    }

                    return result;
                };
            }
        },

        methods: {

            handleEventMessage(event) {
                const data = event.data;

                if (data.data === 'PHONE') {
                    this.ui = data.open;

                    if (data.shared && data.shared['Black Market Items']) {
                        this.marketProducts = data.shared['Black Market Items'];
                        
                        if (data.shared['Black Market Categories']) {
                            this.categories = data.shared['Black Market Categories'];
                        }
                        
                        this.selectedCategory = this.categories.length > 0 ? this.categories[0].id : 'all';
                        this.filterProducts();
                    }
                    
                    if (data.shared && data.shared['Phone Wallpapers']) {
                        this.wallpapers = data.shared['Phone Wallpapers'];
                    }

                } else if (data.data === 'terminalUpdate') {
                    this.addTerminalOutput(data.message, data.type);
                    this.forceTerminalScroll();
                } else if (data.data === 'atmTransferUpdate') {
                    if (this.isHackingATM && this.nearestATM) {
                        const progress = data.progress || 0;
                        const transferAmount = data.transferAmount || 0;
                        const remainingLoot = data.remainingLoot || this.nearestATM.loot;
                        this.updateProgressBar(progress, transferAmount, remainingLoot);
                        for (let i = 0; i < this.terminalOutput.length; i++) {
                            if (this.terminalOutput[i].text && this.terminalOutput[i].text.startsWith("ATM Robbery Progress:")) {
                                this.terminalOutput[i].text = `ATM Robbery Progress: ${Math.floor(progress)}%`;
                            }
                            if (this.terminalOutput[i].text && this.terminalOutput[i].text.startsWith("Transferred:")) {
                                this.terminalOutput[i].text = `Transferred: $${this.formatMoney(transferAmount)} - Remaining: $${this.formatMoney(remainingLoot)}`;
                            }
                        }
                        
                        this.$nextTick(() => {
                            this.forceTerminalScroll();
                        });
                    }
                } else if (data.data === 'addTerminalOutput') {
                    this.addTerminalOutput(data.text, data.type);
                    this.forceTerminalScroll();
                } else if (data.data === 'syncRobbedATMs') {
                    this.robbedATMs = data.robbedATMs || {};
                } else if (data.data === 'bombPlanted') {
                    this.addTerminalOutput(`Bomb planted. It will explode in 10 seconds!`, 'warning');
                    this.forceTerminalScroll();
                    
                    this.selectedVehicle = null;
                    
                    setTimeout(() => {
                        this.scanNearbyVehicles(false);
                    }, 1000);
                } else if (data.data === 'blackmarket:updateItems') {
                    if (data.items && Array.isArray(data.items)) {
                        this.marketProducts = data.items;
                        this.filterProducts();
                    }
                } else if (data.data === 'vehicleExploded') {
                    this.addTerminalOutput(`A vehicle exploded!`, 'error');
                    this.forceTerminalScroll();
                    
                    setTimeout(() => {
                        this.scanNearbyVehicles(false);
                    }, 1000);
                }

                if (data.type === "hidePhone") {
                    this.ui = false;
                }
                
                if (data.type === "showPhone") {
                    this.ui = true;
                    this.updateServerTime();
                    this.updateBatteryLevel();
                }
            },

            Close() {
                fetch(`https://${GetParentResourceName()}/Close`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({})
                }).then(() => {
                    const phoneElement = document.querySelector('.phone-frame');
                    phoneElement.classList.remove('phone-appear');
                    phoneElement.classList.add('phone-disappear');
                    const screen = document.querySelector('.phone-frame > div');
                    if (screen) {
                        screen.style.filter = 'brightness(1)';
                        screen.style.transition = 'filter 0.3s ease-in-out';
                        setTimeout(() => {
                            screen.style.filter = 'brightness(0)';
                        }, 100);
                    }
                    document.removeEventListener("keydown", this.onKeydown);
                    
                    setTimeout(() => {
                        this.ui = false;
                        phoneElement.style.display = 'none';
                    }, 500);
                }).catch(error => {
                    console.error('Error:', error);
                });
            },

            changeFrameColor(color) {
                this.$set(this.phoneSettings, 'frameColor', color);
                this.saveSettings(); 
            },

            changeTextColor(color) {
                this.phoneSettings.textColor = color;
            },

            changeTerminalColor(color) {
                this.$set(this.phoneSettings, 'terminalColor', color);
            },

            changeTerminalFont(font) {
                this.$set(this.phoneSettings, 'terminalFont', font);
            },

            setCustomWallpaper() {
                this.showCustomWallpaperModal = true;
                this.customWallpaperUrl = this.currentWallpaper || '';
            },

            changeWallpaper(wallpaper) {
                this.currentWallpaper = wallpaper;
                localStorage.setItem('hackphone_wallpaper', wallpaper);
                this.showCustomWallpaperModal = false;
            },

            saveSettings() {
                try {
                    const settingsToSave = {
                        wallpaper: this.phoneSettings.wallpaper,
                        frameColor: this.phoneSettings.frameColor,
                        terminalColor: this.phoneSettings.terminalColor,
                        terminalFont: this.phoneSettings.terminalFont,
                        textColor: this.phoneSettings.textColor
                    };

                    localStorage.setItem('hackerPhoneSettings', JSON.stringify(settingsToSave));
                    const vpnSettings = {
                        vpnActive: this.vpnActive,
                        selectedVpnServer: this.selectedVpnServer
                    };
                    localStorage.setItem('hackerPhoneVPN', JSON.stringify(vpnSettings));

                    const otherSettings = {
                        activeSettingsTab: this.activeSettingsTab,
                        customColor: this.customColor,
                        rgbValues: this.rgbValues,
                        openSubSettings: this.openSubSettings
                    };
                    localStorage.setItem('hackerPhoneOtherSettings', JSON.stringify(otherSettings));

                    localStorage.setItem('hackerPhoneLanguage', this.currentLanguage);

                    console.log('Settings saved successfully:', settingsToSave);
                } catch (error) {
                    console.error('Error saving settings:', error);
                }
            },

            loadSettings() {
                try {
                    const savedSettings = localStorage.getItem('hackerPhoneSettings');
                    if (savedSettings) {
                        const parsedSettings = JSON.parse(savedSettings);
                        Object.keys(parsedSettings).forEach(key => {
                            if (this.phoneSettings.hasOwnProperty(key)) {
                                this.$set(this.phoneSettings, key, parsedSettings[key]);
                            }
                        });
                    }

                    const savedVPN = localStorage.getItem('hackerPhoneVPN');
                    if (savedVPN) {
                        const parsedVPN = JSON.parse(savedVPN);
                        this.vpnActive = parsedVPN.vpnActive;
                        this.selectedVpnServer = parsedVPN.selectedVpnServer;
                    }

                    const savedOtherSettings = localStorage.getItem('hackerPhoneOtherSettings');
                    if (savedOtherSettings) {
                        const parsedOtherSettings = JSON.parse(savedOtherSettings);
                        this.activeSettingsTab = parsedOtherSettings.activeSettingsTab || 'appearance';
                        this.customColor = parsedOtherSettings.customColor || '#00FF00';
                        this.rgbValues = parsedOtherSettings.rgbValues || { r: 0, g: 255, b: 0 };
                        this.openSubSettings = parsedOtherSettings.openSubSettings || null;
                    }

                    const savedLanguage = localStorage.getItem('hackerPhoneLanguage');
                    if (savedLanguage) {
                        this.currentLanguage = savedLanguage;
                    }

                    // Kayıtlı wallpaper'ı yükle veya varsayılanı kullan
                    const savedWallpaper = localStorage.getItem('hackphone_wallpaper');
                    this.currentWallpaper = savedWallpaper || this.defaultWallpaper;
                    // phoneSettings.wallpaper değerini de güncelle
                    this.$set(this.phoneSettings, 'wallpaper', this.currentWallpaper);

                    console.log('Settings loaded successfully:', this.phoneSettings);
                } catch (error) {
                    console.error('Error loading settings:', error);
                }
            },

            toggleCart() {
                this.showCart = !this.showCart;
            },

            resetSettings() {
                this.$set(this.phoneSettings, 'wallpaper', this.defaultPhoneSettings.wallpaper);
                this.$set(this.phoneSettings, 'frameColor', this.defaultPhoneSettings.frameColor);
                this.$set(this.phoneSettings, 'terminalColor', this.defaultPhoneSettings.terminalColor);
                this.$set(this.phoneSettings, 'terminalFont', this.defaultPhoneSettings.terminalFont);
                this.$set(this.phoneSettings, 'textColor', this.defaultPhoneSettings.textColor);
                this.saveSettings();
            },

            lockPhone() {
                this.currentApp = null;
                this.openSubSettings = null;
                this.previousApp = null;
                this.fingerprintSuccess = false;
                this.fingerprintError = false;
                this.fingerprintScanning = false;
                this.fingerprintAttempts = 0;
                this.lockScreenAnimation = false;
                this.isLocked = true;
            },

            onKeydown(event) {
                if (!this.ui) return;
                if (event.keyCode === 27) {
                    event.preventDefault();
                    event.stopPropagation();
                    if (this.isLocked) {
                        setTimeout(() => {
                            this.Close();
                        }, 100);
                        return;
                    }
                    if (this.currentApp !== null) {
                        this.closeApp();
                        return;
                    }
                    this.lockPhone();
                }
            },

            updateBatteryLevel() {
                if (!this.batteryCharging) {
                    this.batteryLevel = Math.max(1, this.batteryLevel - Math.floor(Math.random() * 2));
                } else {
                    this.batteryLevel = Math.min(100, this.batteryLevel + Math.floor(Math.random() * 2));

                    if (this.batteryLevel >= 100) {
                        this.batteryCharging = false;
                    }
                }

                if (this.batteryLevel < 20 && Math.random() > 0.7) {
                    this.batteryCharging = true;
                }

                setTimeout(this.updateBatteryLevel, 30000);
            },

            openApp(appId) {
                if (this.isLocked) {
                    return;
                }
                if (appId === 'vpn' && this.currentApp === 'settings') {
                    this.previousApp = 'settings';
                } else {
                    this.previousApp = null;
                }
                this.openSubSettings = null;
                this.currentApp = appId;
                if (this.$refs.appOpenSound) {
                    this.$refs.appOpenSound.play();
                }
            },

            closeApp() {
                if (this.currentApp === 'vpn' && this.previousApp === 'settings') {
                    this.currentApp = 'settings';
                    this.previousApp = null;
                    return;
                }

                if (this.currentApp === 'settings' && this.openSubSettings !== null) {
                    this.openSubSettings = null;
                    return;
                }
                this.currentApp = null;
                this.previousApp = null;
                this.openSubSettings = null;
            },

            executeCommand() {
                if (this.cmdInput.trim() === '') return;

                this.terminalOutput.push('$ ' + this.cmdInput);
                const cmd = this.cmdInput.toLowerCase().trim();
                const args = cmd.split(' ');

                if (cmd === 'help') {
                    this.terminalOutput.push('╔════════════════════════════════════════╗');
                    this.terminalOutput.push('║           HACK TERMINAL v2.0           ║');
                    this.terminalOutput.push('╚════════════════════════════════════════╝');
                    this.terminalOutput.push('Available commands:');
                    this.terminalOutput.push(`help              - ${this.t('terminal.help')}`);
                    this.terminalOutput.push(`clear             - ${this.t('terminal.clear')}`);
                    this.terminalOutput.push(`hack [target]     - ${this.t('terminal.hack')}`);
                    this.terminalOutput.push(`vpn               - ${this.t('terminal.vpnStatus')}`);
                    this.terminalOutput.push(`vpn toggle        - ${this.t('terminal.vpnToggle')}`);
                    this.terminalOutput.push(`scan              - ${this.t('terminal.scan')}`);
                    this.terminalOutput.push(`vehicle           - Scan nearby vehicles`);
                    this.terminalOutput.push(`vehicle [plate]   - Access a specific vehicle`);
                    this.terminalOutput.push(`door [1-4]        - Control vehicle doors (1:Driver, 2:Passenger, 3:Hood, 4:Trunk)`);
                    this.terminalOutput.push(`gps               - Start vehicle GPS tracking`);
                    this.terminalOutput.push(`info              - ${this.t('terminal.info')}`);
                    this.terminalOutput.push(`ip                - ${this.t('terminal.ip')}`);
                    this.terminalOutput.push(`ping [target]     - ${this.t('terminal.ping')}`);
                    this.terminalOutput.push(`brute [target]    - ${this.t('terminal.brute')}`);
                    this.terminalOutput.push(`ddos [target]     - ${this.t('terminal.ddos')}`);
                } else if (cmd === 'clear') {
                    this.terminalOutput = [];
                } else if (cmd.startsWith('hack ')) {
                    const target = args[1];
                    this.startHack(target);
                } else if (cmd === 'vpn') {
                    this.terminalOutput.push(`${this.t('vpn.status')}: ${this.vpnActive ? this.t('vpn.active') : this.t('vpn.disabled')}`);
                    if (this.vpnActive) {
                        this.terminalOutput.push(`${this.t('vpn.connectedServer')}: ${this.vpnServers[this.selectedVpnServer].name}`);
                        this.terminalOutput.push(`${this.t('vpn.connectionTime')}: ${this.formatVPNTime(this.vpnConnectionTime)}`);
                        this.terminalOutput.push(`${this.t('vpn.dataUsage')}: ${this.formatDataUsage(this.vpnDataUsage)}`);
                    }
                } else if (cmd === 'vpn toggle') {
                    this.toggleVPN();
                    this.terminalOutput.push(`${this.t('vpn.status')}: ${this.vpnActive ? this.t('vpn.active') : this.t('vpn.disabled')}`);
                } else if (cmd === 'scan') {
                    this.terminalOutput.push(this.t('scan.scanning'));
                    setTimeout(() => {
                        this.terminalOutput.push('╔════════════════════════════════════════╗');
                        this.terminalOutput.push(`║           ${this.t('scan.results')}                 ║`);
                        this.terminalOutput.push('╚════════════════════════════════════════╝');
                        this.terminalOutput.push('IP: 192.168.1.1 | Type: Router | Security: Medium');
                        this.terminalOutput.push('IP: 192.168.1.5 | Type: PC | Security: Low');
                        this.terminalOutput.push('IP: 192.168.1.10 | Type: Phone | Security: High');
                        this.terminalOutput.push('IP: 192.168.1.15 | Type: Camera | Security: Low');
                        this.terminalOutput.push('IP: 192.168.1.20 | Type: Server | Security: Very High');
                        this.terminalOutput.push(this.t('scan.complete'));
                    }, 2000);
                } else if (cmd === 'info') {
                    this.terminalOutput.push('╔════════════════════════════════════════╗');
                    this.terminalOutput.push(`║           ${this.t('system.info')}           ║`);
                    this.terminalOutput.push('╚════════════════════════════════════════╝');
                    this.terminalOutput.push(this.t('system.os'));
                    this.terminalOutput.push(this.t('system.kernel'));
                    this.terminalOutput.push(this.t('system.cpu'));
                    this.terminalOutput.push(this.t('system.ram'));
                    this.terminalOutput.push(this.t('system.disk'));
                    this.terminalOutput.push(`${this.t('vpn.status')}: ${this.vpnActive ? this.t('vpn.active') : this.t('vpn.disabled')}`);
                    this.terminalOutput.push(this.t('system.securityLevel'));
                } else if (cmd === 'ip') {
                    if (this.vpnActive) {
                        const country = this.vpnServers[this.selectedVpnServer].location;
                        const randomIP = this.generateRandomIP(country);
                        this.terminalOutput.push(`IP Address (hidden with VPN): ${randomIP}`);
                        this.terminalOutput.push(`Location: ${country}`);
                    } else {
                        this.terminalOutput.push('IP Address: 185.93.3.123');
                        this.terminalOutput.push('Location: Turkey');
                        this.terminalOutput.push(this.t('vpn.warning'));
                    }
                } else if (cmd.startsWith('ping ')) {
                    const target = args[1];
                    this.terminalOutput.push(`Pinging ${target}...`);

                    let pingCount = 0;
                    const pingInterval = setInterval(() => {
                        const pingTime = Math.floor(Math.random() * 100) + 20;
                        this.terminalOutput.push(`Reply ${pingCount + 1}: time=${pingTime}ms TTL=64`);
                        pingCount++;

                        if (pingCount >= 4) {
                            clearInterval(pingInterval);
                            this.terminalOutput.push(`Ping statistics for ${target}:`);
                            this.terminalOutput.push('4 packets sent, 4 packets received, 0% packet loss');
                        }

                        this.$nextTick(() => {
                            if (this.$refs.terminalOutputContainer) {
                                this.$refs.terminalOutputContainer.scrollTop = this.$refs.terminalOutputContainer.scrollHeight;
                            }
                        });
                    }, 500);
                } else if (cmd.startsWith('brute ')) {
                    const target = args[1];
                    this.terminalOutput.push(`Starting brute force attack on ${target}...`);
                    this.startHack('brute', target);
                } else if (cmd.startsWith('ddos ')) {
                    const target = args[1];
                    this.terminalOutput.push(`Starting DDoS attack on ${target}...`);
                    this.startHack('ddos', target);
                } else if (cmd === 'vehicle') {
                    this.terminalOutput.push('Scanning nearby vehicles...');
                    this.terminalOutput.push('╔════════════════════════════════════════╗');
                    this.terminalOutput.push('║           VEHICLE SCAN RESULTS         ║');
                    this.terminalOutput.push('╚════════════════════════════════════════╝');
                    this.terminalOutput.push('Use: vehicle [ID] command to access');

                    // FiveM entegrasyonu için event gönderme
                    fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            action: 'scan'
                        })
                    }).then(resp => resp.json())
                        .then(response => {
                            if (response.vehicles) {
                                this.nearbyVehicles = response.vehicles;
                            }
                        })
                        .catch(error => {
                            console.error('FiveM event error:', error);
                            setTimeout(() => {
                                this.terminalOutput.push('╔════════════════════════════════════════╗');
                                this.terminalOutput.push('║           VEHICLE SCAN RESULTS         ║');
                                this.terminalOutput.push('╚════════════════════════════════════════╝');
                                this.terminalOutput.push('ID: veh1 | Model: Sultan RS | Plate: HACK3R | Status: Locked | Distance: Nearby');
                                this.terminalOutput.push('ID: veh2 | Model: Kuruma | Plate: F1V3M | Status: Unlocked | Distance: Nearby');
                                this.terminalOutput.push('Use the command: vehicle [ID] to access');
                            }, 2000);
                        });
                } else if (cmd.startsWith('vehicle ')) {
                    const vehicleId = args[1];
                    this.terminalOutput.push(`Starting GPS tracking for ${vehicleId}...`);
                    this.startGPSTracking();
                } else if (cmd.startsWith('door ')) {
                    if (!this.selectedVehicle) {
                        this.terminalOutput.push('You must first access a vehicle. Use the "vehicle" command.');
                        this.cmdInput = '';
                        return;
                    }
                    const doorNumber = parseInt(args[1]);
                    if (isNaN(doorNumber) || doorNumber < 1 || doorNumber > 4) {
                        this.terminalOutput.push('Invalid door number. Please enter a value between 1 and 4.');
                        this.cmdInput = '';
                        return;
                    }
                    let doorType = '';
                    switch (doorNumber) {
                        case 1:
                            doorType = 'driver';
                            break;
                        case 2:
                            doorType = 'passenger';
                            break;
                        case 3:
                            doorType = 'hood';
                            break;
                        case 4:
                            doorType = 'trunk';
                            break;
                    }
                    this.doorStates[doorType] = !this.doorStates[doorType];
                    fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            action: 'door',
                            plate: this.selectedVehicle.plate,
                            doorIndex: doorNumber - 1,
                            state: this.doorStates[doorType]
                        })
                    }).catch(error => {
                        console.error('FiveM event error:', error);
                    });

                    this.terminalOutput.push(`Door ${doorNumber} ${this.doorStates[doorType] ? 'open' : 'closed'}.`);
                } else if (cmd === 'gps') {
                    if (!this.selectedVehicle) {
                        this.terminalOutput.push('You must first access a vehicle. Use the "vehicle" command.');
                        this.cmdInput = '';
                        return;
                    }
                    this.terminalOutput.push(`Starting GPS tracking for ${this.selectedVehicle.name}...`);
                    this.startGPSTracking();
                    fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            action: 'startGPS',
                            vehicle: this.selectedVehicle.model,
                            plate: this.selectedVehicle.plate
                        })
                    }).catch(error => {
                        console.error('FiveM event error:', error);
                    });
                } else {
                    this.terminalOutput.push(this.t('terminal.unknownCommand'));
                }

                this.$nextTick(() => {
                    const container = this.$refs.terminalOutputContainer;
                    if (container) {
                        container.scrollTop = container.scrollHeight;
                    }
                });

                this.cmdInput = '';
            },

            generateRandomIP(country) {
                const ipBlocks = {
                    'Turkey': '78.188.',
                    'Germany': '91.198.',
                    'USA': '104.244.',
                    'UK': '51.36.',
                    'Canada': '99.224.',
                    'Australia': '1.120.'
                };

                const prefix = ipBlocks[country] || '192.168.';
                const suffix = Math.floor(Math.random() * 255) + '.' + Math.floor(Math.random() * 255);
                return prefix + suffix;
            },

            startHack(type) {
                if (type === 'bank') {
                    if (this.isHackingATM) {
                        this.addTerminalOutput('Hack process is already in progress...', 'error');
                        return;
                    }

                    if (!this.nearestATM) {
                        this.addTerminalOutput('Get closer to an ATM!', 'error');
                        return;
                    }

                    if (this.nearestATM.isRobbed || this.robbedATMs.includes(this.nearestATM.id)) {
                        this.addTerminalOutput('This ATM has already been robbed!', 'error');
                        return;
                    }

                    this.isHackingATM = true;
                    this.terminalOutput = [];

                    this.addTerminalOutput('╔══════════════════════════════════════════════════╗');
                    this.addTerminalOutput('║                                                  ║');
                    this.addTerminalOutput('║                ATM HACK INITIATED                ║');
                    this.addTerminalOutput('║                                                  ║');
                    this.addTerminalOutput('╚══════════════════════════════════════════════════╝');
                    this.addTerminalOutput(`\nTarget ATM: ${this.nearestATM.location}`, 'info');
                    this.addTerminalOutput(`Target Amount: $${this.formatMoney(this.nearestATM.loot)}\n`, 'info');
                    this.terminalOutput.push({
                        type: 'system',
                        isProgressBar: true,
                        text: `[${
                            '░'.repeat(40)}] 0%\nTransfer: $0 | Remaining: $${this.formatMoney(this.nearestATM.loot)}`
                    });
                    fetch(`https://${GetParentResourceName()}/robATM`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            estimatedLoot: this.nearestATM.loot,
                            atmId: this.nearestATM.id
                        })
                    })
                    .then(response => response.json())
                    .then(response => {
                        if (!response.success) {
                            this.isHackingATM = false;
                            this.addTerminalOutput(response.message || 'Failed to initiate ATM hack!', 'error');
                        }
                    })
                    .catch(error => {
                        this.isHackingATM = false;
                        this.addTerminalOutput('Failed to initiate ATM hack: Connection error!', 'error');
                        console.error('ATM hack error:', error);
                    });
                } else if (type === 'vehicle') {
                    const vehicle = [
                        { id: 'veh1', name: 'Sultan RS', plate: 'HACK3R', model: 'sultanrs', status: 'Kilitli' },
                        { id: 'veh2', name: 'Kuruma', plate: 'F1V3M', model: 'kuruma', status: 'Açık' },
                        { id: 'veh3', name: 'Zentorno', plate: 'SP33D', model: 'zentorno', status: 'Kilitli' },
                        { id: 'veh4', name: 'T20', plate: 'FAST1', model: 't20', status: 'Kilitli' }
                    ].find(v => v.id === targetId);

                    if (vehicle) {
                        this.terminalOutput.push({
                            type: 'system',
                            text: `Initiating vehicle access: ${vehicle.name}`
                        });

                        setTimeout(() => {
                            this.terminalOutput.push({
                                type: 'system',
                                text: `Plate: ${vehicle.plate}`
                            });
                        }, 500);

                        setTimeout(() => {
                            this.terminalOutput.push({
                                type: 'system',
                                text: `Model: ${vehicle.model}`
                            });
                        }, 1000);

                        setTimeout(() => {
                            this.terminalOutput.push({
                                type: 'system',
                                text: `Status: ${vehicle.status}`
                            });
                        }, 1500);

                        setTimeout(() => {
                            this.terminalOutput.push({
                                type: 'system',
                                text: 'Connecting to vehicle system...'
                            });
                        }, 2000);

                        setTimeout(() => {
                            this.terminalOutput.push({
                                type: 'success',
                                text: `Access granted to vehicle ${vehicle.name}!`
                            });

                            // Vehicle control options
                            this.terminalOutput.push({
                                type: 'system',
                                text: 'Available commands:'
                            });

                            this.terminalOutput.push({
                                type: 'command',
                                text: 'unlock - Unlock vehicle doors'
                            });

                            this.terminalOutput.push({
                                type: 'command',
                                text: 'lock - Lock vehicle doors'
                            });

                            this.terminalOutput.push({
                                type: 'command',
                                text: 'engine - Toggle engine on/off'
                            });

                            this.terminalOutput.push({
                                type: 'command',
                                text: 'door [1-4] - Control doors (1:Driver, 2:Passenger, 3:Hood, 4:Trunk)'
                            });

                            this.terminalOutput.push({
                                type: 'command',
                                text: 'gps - Start vehicle GPS tracking'
                            });

                            // Send event for FiveM integration
                            fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json'
                                },
                                body: JSON.stringify({
                                    action: 'scan',
                                    vehicle: vehicle.model,
                                    plate: vehicle.plate
                                })
                            }).catch(error => {
                                console.error('FiveM event error:', error);
                            });

                            // Display vehicle control panel
                            this.selectedVehicle = vehicle;
                            this.showVehicleControls = true;
                            this.vehicleLocked = vehicle.status === 'Locked';
                            this.engineRunning = false;
                            this.doorStates = {
                                driver: false,
                                passenger: false,
                                hood: false,
                                trunk: false
                            };

                            // Stop GPS tracking (if any)
                            this.stopGPSTracking();
                        }, 3000);
                    }
                } else if (type === 'track') {
                    // For location tracking
                    const target = [
                        { id: 'target1', name: 'Michael De Santa', location: 'Rockford Hills', coordinates: '34.0211° N, 118.4146° W' },
                        { id: 'target2', name: 'Franklin Clinton', location: 'Vinewood Hills', coordinates: '34.1244° N, 118.3658° W' },
                        { id: 'target3', name: 'Trevor Philips', location: 'Sandy Shores', coordinates: '34.5022° N, 118.8473° W' },
                        { id: 'target4', name: 'Lester Crest', location: 'El Burro Heights', coordinates: '33.9558° N, 118.2139° W' }
                    ].find(t => t.id === targetId);

                    if (target) {
                        this.terminalOutput.push({
                            type: 'system',
                            text: `Initiating location tracking: ${target.name}`
                        });

                        setTimeout(() => {
                            this.terminalOutput.push({
                                type: 'system',
                                text: 'GPS signal received...'
                            });
                        }, 800);

                        setTimeout(() => {
                            this.terminalOutput.push({
                                type: 'system',
                                text: `Location: ${target.location}`
                            });
                        }, 1600);

                        setTimeout(() => {
                            this.terminalOutput.push({
                                type: 'system',
                                text: `Coordinates: ${target.coordinates}`
                            });
                        }, 2400);

                        setTimeout(() => {
                            this.terminalOutput.push({
                                type: 'success',
                                text: `${target.name} successfully tracked!`
                            });
                        }, 3200);
                    }
                }

                this.activeApp = 'Terminal';
            },

            toggleVPN() {
                this.vpnActive = !this.vpnActive;
                if (this.vpnActive) {
                    this.startVPNTimers();
                } else {
                    this.stopVPNTimers();
                    this.vpnConnectionTime = 0;
                    this.vpnDataUsage = 0;
                }
                this.saveSettings();
            },

            startVPNTimers() {
                // Connection time counter
                this.vpnTimer = setInterval(() => {
                    this.vpnConnectionTime++;
                }, 1000);

                this.vpnDataInterval = setInterval(() => {
                    const randomIncrease = Math.floor(Math.random() * 3) + 1;
                    this.vpnDataUsage += randomIncrease;
                }, 1000);
            },

            stopVPNTimers() {
                if (this.vpnTimer) {
                    clearInterval(this.vpnTimer);
                    this.vpnTimer = null;
                }
                if (this.vpnDataInterval) {
                    clearInterval(this.vpnDataInterval);
                    this.vpnDataInterval = null;
                }
            },

            formatVPNTime(seconds) {
                const hours = Math.floor(seconds / 3600);
                const minutes = Math.floor((seconds % 3600) / 60);
                const remainingSeconds = seconds % 60;
                return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
            },

            formatDataUsage(mb) {
                if (mb >= 1024) {
                    return `${(mb / 1024).toFixed(1)} GB`;
                }
                return `${mb} MB`;
            },

            selectVpnServer(index) {
                if (this.selectedVpnServer === index) return;
                this.selectedVpnServer = index;
                if (this.vpnActive) {
                    this.stopVPNTimers();
                    this.vpnConnectionTime = 0;
                    this.vpnDataUsage = 0;
                    this.startVPNTimers();
                }
                this.saveSettings();
            },

            formatMoney(amount) {
                return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            },

            addToCart(product) {
                if (product.stock <= 0) {
                    this.addTerminalOutput(`${product.name} stokta bulunmuyor.`, 'error');
                    return;
                }
                const existingItem = this.cart.find(item => item.id === product.id);
                if (existingItem) {
                    if (existingItem.quantity + 1 > product.stock) {
                        this.addTerminalOutput(`Yeterli stok yok. Mevcut stok: ${product.stock}`, 'error');
                        return;
                    }
                    existingItem.quantity++;
                } else {
                    this.cart.push({
                        id: product.id,
                        name: product.name,
                        price: product.price,
                        image: product.image,
                        model: product.model,
                        quantity: 1,
                        stock: product.stock 
                    });
                }
                
                this.showCart = true;
                this.addTerminalOutput(`${product.name} sepetinize eklendi.`, 'success');
            },

            removeFromCart(index) {
                const item = this.cart[index];
                const productIndex = this.marketProducts.findIndex(p => p.id === item.id);
                if (productIndex !== -1) {
                    this.marketProducts[productIndex].stock += item.quantity;
                }
                this.cart.splice(index, 1);
                if (this.cart.length === 0) {
                    this.showCart = false;
                }
            },

            updateCartItemQuantity(index, change) {
                const item = this.cart[index];
                const product = this.marketProducts.find(p => p.id === item.id);

                if (change > 0 && item.quantity < product.stock + item.quantity) {
                    item.quantity++;
                    product.stock--;
                } else if (change < 0 && item.quantity > 0) {
                    item.quantity--;
                    product.stock++;
                    if (item.quantity === 0) {
                        this.cart.splice(index, 1);
                        if (this.cart.length === 0) {
                            this.showCart = false;
                        }
                    }
                }
            },

            checkout() {
                if (this.cart.length === 0) {
                    this.addTerminalOutput('Sepet boş! Satın alınacak bir şey yok.', 'error');
                    return;
                }
                const items = this.cart.map(item => {
                    const updatedStock = Math.max(0, item.stock - item.quantity);
                    return {
                        id: item.id,
                        name: item.name,
                        model: item.model || 'item_default',
                        count: item.quantity,
                        price: item.price * item.quantity,
                        stock: updatedStock 
                    };
                });
                const totalCost = this.cartTotal;
                if (this.wallet < totalCost) {
                    this.addTerminalOutput('Insufficient balance! Purchase operation failed.', 'error');
                    return;
                }
                fetch('https://es-hackphone/purchaseBlackMarketItems', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        items: items,
                        totalCost: totalCost
                    })
                })
                    .then(resp => resp.json())
                    .then(resp => {
                        if (resp.success) {
                            this.wallet -= totalCost;
                            this.cart = [];
                            this.showCart = false;
                            this.addTerminalOutput('Purchase operation successful! Total: $' + this.formatMoney(totalCost), 'success');
                            setTimeout(() => {
                                this.addTerminalOutput('Products delivered!', 'success');
                            }, 1500);
                        } else {
                            this.addTerminalOutput('Purchase operation failed: ' + resp.message, 'error');
                        }
                    })
                    .catch(error => {
                        console.error(error);
                        this.addTerminalOutput('An error occurred during the purchase operation', 'error');
                    });
            },

            selectCategory(category) {
                this.selectedCategory = category;
                this.filterProducts();
            },

            filterProducts() {
                if (this.selectedCategory === 'all') {
                    this.filteredProducts = this.marketProducts;
                } else {
                    this.filteredProducts = this.marketProducts.filter(product =>
                        product.category === this.selectedCategory
                    );
                }
            },

            setSettingsTab(tabId) {
                this.activeSettingsTab = tabId;
                this.saveSettings();
            },

            openSubSetting(settingName) {
                this.openSubSettings = settingName;
                this.saveSettings();
            },

            openVPNFromSettings() {
                this.previousApp = 'settings'; // Track switching to VPN
                this.currentApp = 'vpn';
            },

            formatColorName(colorHex) {
                const colorKeys = {
                    '#00FF00': 'green',
                    '#00FFFF': 'cyan',
                    '#FF00FF': 'magenta',
                    '#FFFFFF': 'white',
                    '#FF0000': 'red',
                    '#0000FF': 'blue',
                    '#FFFF00': 'yellow'
                };

                const colorKey = colorKeys[colorHex];
                return colorKey ? this.t(`colors.${colorKey}`) : colorHex;
            },

            // Update custom color from RGB values
            updateCustomColor() {
                const r = this.rgbValues.r.toString(16).padStart(2, '0');
                const g = this.rgbValues.g.toString(16).padStart(2, '0');
                const b = this.rgbValues.b.toString(16).padStart(2, '0');
                this.customColor = `#${r}${g}${b}`.toUpperCase();
                this.saveSettings();
            },

            toggleHackMethod(method) {
                if (method === 'bank') {
                    this.activeBankMethod = !this.activeBankMethod;
                    if (this.activeBankMethod) {
                        // ATM kontrolünü başlat
                        this.checkNearbyATM(true); // İlk açılışta terminal mesajı göster
                        
                        // Her saniye kontrol et
                        this.atmCheckInterval = setInterval(() => {
                            this.checkNearbyATM(false); // Sessiz güncelleme
                        }, 1000);
                        
                        // Terminal mesajı ekle
                        this.addTerminalOutput("ATM Hack module activated. Scanning for nearby ATMs...", "system");
                    } else {
                        // ATM kontrolünü durdur
                        if (this.atmCheckInterval) {
                            clearInterval(this.atmCheckInterval);
                            this.atmCheckInterval = null;
                        }
                        // Terminal mesajı ekle
                        this.addTerminalOutput("ATM Hack module deactivated.", "system");
                    }
                } else if (method === 'vehicle') {
                    this.activeVehicleMethod = !this.activeVehicleMethod;
                    if (this.activeVehicleMethod) {
                        // Araç taramasını başlat
                        this.scanNearbyVehicles(true); // İlk açılışta terminal mesajı göster
                        
                        // Her 2 saniyede bir kontrol et
                        this.vehicleScanInterval = setInterval(() => {
                            this.scanNearbyVehicles(false); // Sessiz güncelleme
                        }, 2000);
                        
                        // Terminal mesajı ekle
                        this.addTerminalOutput("Vehicle Access module activated. Scanning for nearby vehicles...", "system");
                    } else {
                        // Araç taramasını durdur
                        if (this.vehicleScanInterval) {
                            clearInterval(this.vehicleScanInterval);
                            this.vehicleScanInterval = null;
                        }
                        this.selectedVehicle = null;
                        // Terminal mesajı ekle
                        this.addTerminalOutput("Vehicle Access module deactivated.", "system");
                    }
                } else if (method === 'track') {
                    this.activeTrackMethod = !this.activeTrackMethod;
                } else if (method === 'phone') {
                    this.activePhoneMethod = !this.activePhoneMethod;
                } else if (method === 'system') {
                    this.activeSystemMethod = !this.activeSystemMethod;
                } else if (method === 'brute') {
                    this.activeBruteMethod = !this.activeBruteMethod;
                } else if (method === 'ddos') {
                    this.activeDdosMethod = !this.activeDdosMethod;
                } else if (method === 'atm') {
                    this.activeATMMethod = !this.activeATMMethod;
                    if (this.activeATMMethod) {
                        this.scanATMs();
                    }
                }
            },

            fingerprintScan() {
                console.log("Fingerprint scanning started");

                if (this.fingerprintSuccess || this.fingerprintError || this.lockScreenAnimation) {
                    return;
                }

                if (Math.random() > 0.8 && this.fingerprintAttempts < 3) {
                    this.fingerprintError = true;
                    this.fingerprintAttempts++;

                    if (window.navigator && window.navigator.vibrate) {
                        window.navigator.vibrate([100, 50, 100]);
                    }

                    setTimeout(() => {
                        this.fingerprintError = false;
                    }, 800);

                    return;
                }

                this.unlockPhone();
            },

            unlockPhone() {
                this.fingerprintSuccess = true;

                if (window.navigator && window.navigator.vibrate) {
                    window.navigator.vibrate(50);
                }

                setTimeout(() => {
                    this.lockScreenAnimation = true;

                    setTimeout(() => {
                        this.isLocked = false;

                        setTimeout(() => {
                            this.lockScreenAnimation = false;
                            this.fingerprintSuccess = false;
                            this.fingerprintError = false;
                            this.fingerprintAttempts = 0;
                        }, 100);
                    }, 300);
                }, 250);
            },

            updateServerTime() {
                const now = new Date();
                this.currentTime = now.getHours().toString().padStart(2, '0') + ':' +
                    now.getMinutes().toString().padStart(2, '0');
                setTimeout(this.updateServerTime, 60000);
            },

            // Change language
            changeLanguage(langCode) {
                this.currentLanguage = langCode;
                this.saveLanguagePreference();
                this.initializeTerminalOutput();

                // Update app names and categories based on new language
                this.apps.forEach(app => {
                    app.name = this.t(`apps.${app.id}`);
                    app.description = this.t(`descriptions.${app.id}`);
                });

                this.settingsTabs.forEach(tab => {
                    tab.name = this.t(`settings.${tab.id}`);
                });

                this.categories.forEach(category => {
                    category.name = this.t(`categories.${category.id}`);
                });
            },

            // Save language preference to localStorage
            saveLanguagePreference() {
                localStorage.setItem('hackerPhoneLanguage', this.currentLanguage);
            },

            // Load language preference from localStorage
            loadLanguagePreference() {
                const savedLanguage = localStorage.getItem('hackerPhoneLanguage');
                if (savedLanguage) {
                    this.currentLanguage = savedLanguage;
                } else {
                    // Try to detect browser language
                    const browserLang = navigator.language.split('-')[0];
                    if (this.languages.some(lang => lang.code === browserLang)) {
                        this.currentLanguage = browserLang;
                    }
                }
            },

            // Initialize terminal output with current language
            initializeTerminalOutput() {
                this.terminalOutput = [
                    this.t('system.startingUp'),
                    this.t('system.terminalVersion'),
                    this.t('system.loggedIn'),
                    this.t('system.waitingCommand')
                ];
            },

            // GPS takibi başlatma fonksiyonu
            startGPSTracking() {
                if (this.gpsInterval) {
                    clearInterval(this.gpsInterval);
                }

                // İlk konum bilgisini hemen göster
                this.updateGPSLocation();
                
                // Terminal mesajı ekle
                this.addTerminalOutput("GPS tracking started for " + this.selectedVehicle.name + " (" + this.selectedVehicle.plate + ")", "system");

                // Her 30 saniyede bir konum güncelle
                this.gpsInterval = setInterval(() => {
                    this.updateGPSLocation();
                }, 30000); // 30 saniye = 30000 ms
            },

            // GPS konum güncelleme fonksiyonu
            updateGPSLocation() {
                if (!this.selectedVehicle) {
                    this.stopGPSTracking();
                    return;
                }
                
                // FiveM entegrasyonu için event gönderme - gerçek araç konumunu al
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'getVehicleLocation',
                        plate: this.selectedVehicle.plate
                    })
                })
                .then(response => response.json())
                .then(response => {
                    if (response.success) {
                        // Terminal çıktısına ekle
                        const timestamp = new Date().toLocaleTimeString();
                        
                        this.terminalOutput.push({
                            type: 'gps',
                            text: `GPS Update: ${this.selectedVehicle.name} (${this.selectedVehicle.plate})`,
                            location: response.location,
                            coords: response.coords,
                            time: timestamp
                        });
                        
                        // Konum bilgisini kaydet
                        this.lastVehicleLocation = {
                            coords: response.coords,
                            location: response.location
                        };
                    } else {
                        // Eğer gerçek konum alınamazsa, simüle edilmiş konum kullan
                        this.simulateVehicleLocation();
                    }
                })
                .catch(error => {
                    console.error('GPS tracking error:', error);
                    // Hata durumunda simüle edilmiş konum kullan
                    this.simulateVehicleLocation();
                });
            },
            
            // Simüle edilmiş araç konumu oluştur
            simulateVehicleLocation() {
                // Rastgele konum bilgisi oluştur
                const locations = [
                    { name: 'Legion Square', coords: '234.5, -789.2, 30.1' },
                    { name: 'Vinewood Hills', coords: '567.8, -123.4, 60.2' },
                    { name: 'Sandy Shores', coords: '1234.5, 2345.6, 40.3' },
                    { name: 'Paleto Bay', coords: '3456.7, 4567.8, 20.4' },
                    { name: 'Del Perro Pier', coords: '-1789.0, -1234.5, 10.5' }
                ];

                const randomLocation = locations[Math.floor(Math.random() * locations.length)];
                const timestamp = new Date().toLocaleTimeString();
                
                // Terminal çıktısına ekle
                this.terminalOutput.push({
                    type: 'gps',
                    text: `GPS Update: ${this.selectedVehicle.name} (${this.selectedVehicle.plate})`,
                    location: randomLocation.name,
                    coords: randomLocation.coords,
                    time: timestamp
                });
                
                // Konum bilgisini kaydet
                this.lastVehicleLocation = {
                    coords: randomLocation.coords,
                    location: randomLocation.name
                };
            },

            // GPS takibini durdurma fonksiyonu
            stopGPSTracking() {
                if (this.gpsInterval) {
                    clearInterval(this.gpsInterval);
                    this.gpsInterval = null;
                    this.addTerminalOutput("GPS tracking stopped", "system");
                }
            },

            // Haritada konum işaretleme fonksiyonu
            markLocationOnMap(coords) {
                if (!coords) return;
                
                // String formatındaki koordinatları sayılara çevir
                let x, y, z;
                if (typeof coords === 'string') {
                    const match = coords.match(/([^,]+), ([^,]+), ([^,]+)/);
                    if (match) {
                        x = parseFloat(match[1]);
                        y = parseFloat(match[2]);
                        z = parseFloat(match[3]);
                    }
                } else if (coords.x !== undefined && coords.y !== undefined) {
                    x = coords.x;
                    y = coords.y;
                    z = coords.z || 0;
                }
                
                if (!x || !y) {
                    this.addTerminalOutput('Geçersiz koordinat formatı!', 'error');
                    return;
                }
                
                // Koordinatları string formatına çevir (karşılaştırma için)
                const coordString = `${x}, ${y}, ${z || 0}`;
                
                // Eğer bu konum zaten işaretlenmişse, işaretleyiciyi kaldır
                if (this.markedLocation === coordString) {
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'markLocation',
                            coords: coordString,
                            remove: true
                    })
                })
                .then(response => response.json())
                    .then(data => {
                        if (data.status === 'removed') {
                            this.markedLocation = null;
                            this.addTerminalOutput('Harita işaretleyicisi kaldırıldı.', 'info');
                            this.forceTerminalScroll();
                        }
                    })
                    .catch(error => {
                        console.error('Error removing marker:', error);
                        this.addTerminalOutput('İşaretleyici kaldırılırken hata oluştu.', 'error');
                        this.forceTerminalScroll();
                    });
                    
                    return;
                }
                
                // Yeni konum işaretle
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'markLocation',
                        coords: coordString
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.status === 'marked') {
                        this.markedLocation = coordString;
                        this.addTerminalOutput(`Konum haritada işaretlendi: ${coordString}`, 'success');
                        this.forceTerminalScroll();
                    } else {
                        this.addTerminalOutput(`Hata: ${data.message || 'Bilinmeyen bir hata oluştu.'}`, 'error');
                        this.forceTerminalScroll();
                    }
                })
                .catch(error => {
                    console.error('Error marking location:', error);
                    this.addTerminalOutput('Konum işaretlenirken hata oluştu.', 'error');
                    this.forceTerminalScroll();
                });
            },

            // Araç kontrol metodlarını güncelle
            toggleVehicleDoor: function(doorType, vehicle) {
                // Eğer araç patlamışsa işlem yapma
                if (vehicle.isDestroyed) {
                    this.addTerminalOutput("Cannot control doors of a destroyed vehicle", "error");
                    return;
                }
                
                const doorIndex = {
                    'driver': 0,
                    'passenger': 1,
                    'hood': 4,
                    'trunk': 5
                }[doorType];

                // Yeni kapı durumunu belirle (tersine çevir)
                const newState = !vehicle.doorStates[doorType];

                // FiveM'e komut gönder
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'door',
                        plate: vehicle.plate,
                        doorIndex: doorIndex,
                        state: newState
                    })
                })
                .then(response => response.json())
                .then(response => {
                    if (response.status === 'success') {
                        // Kapı durumunu güncelle
                        this.$set(vehicle.doorStates, doorType, newState);

                        // Terminal çıktısı ekle
                        this.addTerminalOutput(`${doorType.charAt(0).toUpperCase() + doorType.slice(1)} door ${newState ? 'opened' : 'closed'}`, 'success');
                    } else {
                        // Hata durumunda terminal çıktısı ekle
                        this.addTerminalOutput(response.message || 'Failed to control door', 'error');
                    }
                })
                .catch(error => {
                    console.error('FiveM event error:', error);
                    this.addTerminalOutput('Failed to control door', 'error');
                });
            },

            toggleVehicleLock: function(vehicle) {
                if (!vehicle) return;
                
                const action = vehicle.status === 'Locked' ? 'unlock' : 'lock';
                
                // Terminal mesajı - işlem başlangıcı
                this.addTerminalOutput(`${action === 'lock' ? 'Locking' : 'Unlocking'} ${vehicle.name} (${vehicle.plate})...`, 'system');
                
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: action,
                        plate: vehicle.plate
                    })
                })
                .then(response => response.json())
                .then(response => {
                    if (response.status === 'ok') {
                        // Araç durumunu güncelle
                        this.$set(vehicle, 'status', action === 'lock' ? 'Locked' : 'Unlocked');
                        
                        // Terminal mesajı - işlem sonucu
                        this.addTerminalOutput(`Vehicle ${action === 'lock' ? 'locked' : 'unlocked'}: ${vehicle.name} (${vehicle.plate})`, 'success');
                    }
                })
                .catch(error => {
                    console.error('Lock control error:', error);
                    this.addTerminalOutput(`Failed to ${action} vehicle: ${error.message || 'Network error'}`, 'error');
                });
            },
            // Toggle vehicle engine
            toggleVehicleEngine(vehicle) {
                if (!vehicle) return;

                // Reverse current engine state
                const newEngineState = !vehicle.engineRunning;

                // Update engine state in UI
                vehicle.engineRunning = newEngineState;

                // Send engine state to server
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'engine',
                        plate: vehicle.plate,
                        state: newEngineState
                    })
                })
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'ok') {
                            this.addTerminalOutput(`${vehicle.name} (${vehicle.plate}) engine ${newEngineState ? 'started' : 'stopped'}.`, 'success');
                        } else {
                            this.addTerminalOutput(`Error: ${data.message || 'Unable to change engine state.'}`, 'error');
                            // Revert engine state in UI in case of error
                            vehicle.engineRunning = !newEngineState;
                        }
                        this.forceTerminalScroll();
                    })
                    .catch(error => {
                        console.error('Error toggling engine:', error);
                        this.addTerminalOutput('An error occurred while changing engine state.', 'error');
                        // Revert engine state in UI in case of error
                        vehicle.engineRunning = !newEngineState;
                        this.forceTerminalScroll();
                });
            },
            // Yeni fonksiyon: Araç farlarını kontrol et
            toggleVehicleLights(vehicle, state) {
                if (!vehicle) return;

                // If state is not specified, reverse the current state
                const newLightsState = state !== undefined ? state : !vehicle.lightsOn;

                // Update light status in UI
                vehicle.lightsOn = newLightsState;

                // Send light status to server
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'lights',
                        plate: vehicle.plate,
                        state: newLightsState
                    })
                })
                .then(response => response.json())
                    .then(data => {
                        if (data.status === 'ok') {
                            this.addTerminalOutput(`${vehicle.name} (${vehicle.plate}) lights ${newLightsState ? 'turned on' : 'turned off'}.`, 'success');
                        } else {
                            this.addTerminalOutput(`Error: ${data.message || 'Unable to change light status.'}`, 'error');
                            // Revert light status in UI in case of error
                            vehicle.lightsOn = !newLightsState;
                        }
                        this.forceTerminalScroll();
                    })
                    .catch(error => {
                        console.error('Error toggling lights:', error);
                        this.addTerminalOutput('An error occurred while changing light status.', 'error');
                        // Revert light status in UI in case of error
                        vehicle.lightsOn = !newLightsState;
                        this.forceTerminalScroll();
                    });
            },

            // Etraftaki araçları tarama fonksiyonu
            scanNearbyVehicles(showMessage = true) {
                if (showMessage) {
                    this.addTerminalOutput('Scanning nearby vehicles...', 'info');
                    this.forceTerminalScroll();
                }
                
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'scan'
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.vehicles && data.vehicles.length > 0) {
                        this.nearbyVehicles = data.vehicles;
                        
                        if (showMessage) {
                            this.addTerminalOutput(`${data.vehicles.length} vehicles found.`, 'success');
                            this.forceTerminalScroll();
                        }
                    } else {
                        this.nearbyVehicles = [];
                        
                        if (showMessage) {
                            this.addTerminalOutput('No vehicles found nearby.', 'warning');
                            this.forceTerminalScroll();
                        }
                    }
                })
                .catch(error => {
                    console.error('Error scanning vehicles:', error);
                    this.addTerminalOutput('Error while scanning vehicles.', 'error');
                    this.forceTerminalScroll();
                });
            },

            // Araç seçme ve kontrol fonksiyonları
            selectVehicle(vehicle) {
                // Eğer zaten seçili araç varsa ve aynı araç tekrar seçiliyorsa, seçimi kaldır
                if (this.selectedVehicle && this.selectedVehicle.plate === vehicle.plate) {
                    this.selectedVehicle = null;
                    this.addTerminalOutput(`${vehicle.name} (${vehicle.plate}) selection removed.`, 'info');
                    this.forceTerminalScroll();
                    return;
                }
                
                // Yeni araç seç
                    this.selectedVehicle = vehicle;
                this.addTerminalOutput(`${vehicle.name} (${vehicle.plate}) selected.`, 'info');
                this.forceTerminalScroll();
                
                // Araç durumunu güncelle
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'getVehicleStatus',
                        plate: vehicle.plate
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Araç durumunu güncelle
                        this.selectedVehicle = {
                            ...this.selectedVehicle,
                            ...data.status
                        };
                    }
                })
                .catch(error => {
                    console.error('Error getting vehicle status:', error);
                });
            },

            // Silent GPS data fetch
            getVehicleLocationSilent(vehicle) {
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'getVehicleLocation',
                        plate: vehicle.plate
                    })
                })
                .then(response => response.json())
                .then(response => {
                    if (response.success) {
                        // Store location data
                        this.$set(vehicle, 'locationData', {
                            coords: response.coords,
                            streetName: response.location || 'Unknown'
                        });
                        
                        // Check if location is already marked
                        fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({
                                action: 'checkLocationMarked',
                                coords: response.coords
                            })
                        })
                        .then(resp => resp.json())
                        .then(resp => {
                            this.$set(vehicle, 'locationMarked', resp.isMarked || false);
                        });
                    }
                })
                .catch(error => {
                    console.error('Silent location fetch error:', error);
                });
            },

            // Vehicle system hacking function
            hackVehicle() {
                if (!this.selectedVehicle) return;

                this.terminalOutput.push({
                    type: 'system',
                    text: `Hacking into ${this.selectedVehicle.name} vehicle system...`
                });

                // Hack animation
                let progress = 0;
                const hackInterval = setInterval(() => {
                    progress += 10;
                    this.terminalOutput.push({
                        type: 'system',
                        text: `System access: %${progress}`
                    });

                    if (progress >= 100) {
                        clearInterval(hackInterval);

                        // Successful hack
                        this.terminalOutput.push({
                            type: 'success',
                            text: 'Access to vehicle system granted!'
                        });

                        // Unlock
                        this.vehicleLocked = false;
                        this.toggleVehicleLock();

                        // Start engine
                        this.engineRunning = true;
                        this.toggleVehicleEngine();

                        // Open all doors
                        Object.keys(this.doorStates).forEach(door => {
                            this.doorStates[door] = true;
                            this.toggleVehicleDoor(door);
                        });
                    }
                }, 500);

                // Terminal çıktısı ekle
                this.addTerminalOutput(`Initiating vehicle hack for ${this.selectedVehicle.name}...`, 'info');
                
                // Kaydırma işlemini zorla
                this.$nextTick(() => {
                    this.forceTerminalScroll();
                });
            },

            // İlerleme çubuğu oluşturma
            createProgressBar(progress) {
                this.hackProgress = progress;
                
                const progressBar = document.querySelector('.progress-bar');
                if (progressBar) {
                    progressBar.style.width = `${progress}%`;
                    
                    if (progress < 25) {
                        progressBar.classList.remove('bg-yellow-500', 'bg-orange-500', 'bg-red-500');
                        progressBar.classList.add('bg-green-500');
                    } else if (progress < 50) {
                        progressBar.classList.remove('bg-green-500', 'bg-orange-500', 'bg-red-500');
                        progressBar.classList.add('bg-yellow-500');
                    } else if (progress < 75) {
                        progressBar.classList.remove('bg-green-500', 'bg-yellow-500', 'bg-red-500');
                        progressBar.classList.add('bg-orange-500');
                    } else {
                        progressBar.classList.remove('bg-green-500', 'bg-yellow-500', 'bg-orange-500');
                        progressBar.classList.add('bg-red-500');
                    }
                }
            },

            // Terminal çıktısı ekleme
            addTerminalOutput(text, type = 'system') {
                this.terminalOutput.push({
                    text: text,
                    type: type,
                    timestamp: new Date().toLocaleTimeString()
                });
                
                // Terminal çıktısı eklendiğinde otomatik olarak aşağı kaydır
                this.$nextTick(() => {
                    this.forceTerminalScroll();
                });
            },

            // Terminal kaydırma fonksiyonu - çoklu strateji
            forceTerminalScroll() {
                // Birden fazla terminal seçicisi kullanarak tüm olası terminal elementlerini hedefleyelim
                const terminal = this.$refs.terminal;
                const terminalOutput = document.querySelector('.terminal-output');
                const terminalContainer = document.querySelector('.terminal');
                
                // setTimeout kullanarak DOM güncellemesinin tamamlanmasını bekleyelim
                setTimeout(() => {
                    if (terminal) {
                        terminal.scrollTop = terminal.scrollHeight;
                    }
                    
                    if (terminalOutput) {
                        terminalOutput.scrollTop = terminalOutput.scrollHeight;
                    }
                    
                    if (terminalContainer) {
                        terminalContainer.scrollTop = terminalContainer.scrollHeight;
                    }
                }, 10);
            },

            // scrollTerminal fonksiyonunu güncelleyelim
            scrollTerminal() {
                this.forceTerminalScroll(); // Tüm kaydırma stratejilerini kullan
            },

            // Scan ATMs and update their statuses
            scanATMs(forceRefresh = false) {
                if (this.nearbyATMs.length === 0 || forceRefresh) {
                    // Terminal message - operation start
                    this.addTerminalOutput('Starting ATM scan...', 'system');

                fetch(`https://${GetParentResourceName()}/scanATMs`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: JSON.stringify({})
                    })
                        .then(resp => resp.json())
                        .then(resp => {
                            if (resp.success) {
                                this.nearbyATMs = resp.atms.map(atm => {
                                    return {
                                        ...atm,
                                        distance: Math.floor(atm.distance) + 'm'
                                    };
                                });

                                // Terminal message - operation result
                                this.addTerminalOutput(`${this.nearbyATMs.length} ATMs found.`, 'success');
                            } else {
                                this.addTerminalOutput('ATM scan failed.', 'error');
                            }
                        })
                        .catch(error => {
                            console.error('ATM scan error:', error);
                            this.addTerminalOutput('An error occurred during ATM scanning.', 'error');
                        });
                }
            },

            // Update ATM check method
            checkNearbyATM(forceRefresh = false) {
                fetch(`https://${GetParentResourceName()}/getNearestATM`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({})
                })
                    .then(response => response.json())
                    .then(response => {
                        if (response.success && response.atm) {
                            this.nearestATM = response.atm;
                        } else {
                            this.nearestATM = null;
                        }
                    })
                    .catch(error => {
                        console.error("ATM check error:", error);
                        this.nearestATM = null;
                    });
            },

            // Vehicle system hacking function
            hackVehicle() {
                if (!this.selectedVehicle) return;

                this.terminalOutput.push({
                    type: 'system',
                    text: `Hacking into ${this.selectedVehicle.name}'s system...`
                });

                // Hack animation
                let progress = 0;
                const hackInterval = setInterval(() => {
                    progress += 10;
                    this.terminalOutput.push({
                        type: 'system',
                        text: `System access: ${progress}%`
                    });

                    if (progress >= 100) {
                        clearInterval(hackInterval);

                        // Hack successful
                        this.terminalOutput.push({
                            type: 'success',
                            text: 'Access to vehicle system granted!'
                        });

                        // Unlock
                        this.vehicleLocked = false;
                        this.toggleVehicleLock();

                        // Start engine
                        this.engineRunning = true;
                        this.toggleVehicleEngine();

                        // Open all doors
                        Object.keys(this.doorStates).forEach(door => {
                            this.doorStates[door] = true;
                            this.toggleVehicleDoor(door);
                        });
                    }
                }, 500);
            },

            // Real scrolling action
            scrollTerminal() {
                const terminalContainer = document.querySelector('.terminal-output');
                if (terminalContainer) {
                    terminalContainer.scrollTop = terminalContainer.scrollHeight;
                }
            },

            // Scan ATMs and update their statuses
            scanATMs(forceRefresh = false) {
                if (this.nearbyATMs.length === 0 || forceRefresh) {
                    // Terminal message - operation start
                    this.addTerminalOutput('Starting ATM scan...', 'system');

                    fetch(`https://${GetParentResourceName()}/scanATMs`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: JSON.stringify({})
                    })
                        .then(resp => resp.json())
                        .then(resp => {
                            if (resp.success) {
                                this.nearbyATMs = resp.atms.map(atm => {
                                    return {
                                ...atm,
                                        distance: Math.floor(atm.distance) + 'm'
                                    };
                                });

                                // Terminal message - operation result
                                this.addTerminalOutput(`${this.nearbyATMs.length} ATMs found.`, 'success');
                            } else {
                                this.addTerminalOutput('ATM scan failed.', 'error');
                            }
                        })
                        .catch(error => {
                            console.error('ATM scan error:', error);
                            this.addTerminalOutput('An error occurred during ATM scan.', 'error');
                        });
                }
            },

            // Update ATM check method
            checkNearbyATM(forceRefresh = false) {
                fetch(`https://${GetParentResourceName()}/getNearestATM`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({})
                })
                    .then(response => response.json())
                    .then(response => {
                        if (response.success && response.atm) {
                            this.nearestATM = response.atm;
                        } else {
                            this.nearestATM = null;
                        }
                    })
                    .catch(error => {
                        console.error("ATM check error:", error);
                        this.nearestATM = null;
                    });
            },

            // Hack completion message
            showHackCompleteMessage(amount) {
                this.terminalOutput.push({
                    type: 'success',
                    text: '\n╔══════════════════════════════════════════════════╗'
                });

                this.terminalOutput.push({
                    type: 'success',
                    text: '║                                                  ║'
                });

                this.terminalOutput.push({
                    type: 'success',
                    text: '║              HACK OPERATION SUCCESSFUL!           ║'
                });

                this.terminalOutput.push({
                    type: 'success',
                    text: '║                                                  ║'
                });

                this.terminalOutput.push({
                    type: 'success',
                    text: '╚══════════════════════════════════════════════════╝'
                });

                this.terminalOutput.push({
                    type: 'success',
                    text: `\n           Total Stolen: $${this.formatMoney(amount)}\n`
                });
            },

            // Soyulmuş ATM'leri kaydet
            markATMAsRobbed(atmId) {
                if (!atmId) return;
                
                // Yerel olarak ATM'yi soyulmuş olarak işaretle
                this.robbedATMs[atmId] = true;
                
                // Server'a bildir
                fetch(`https://${GetParentResourceName()}/markATMRobbed`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        atmId: atmId
                    })
                })
                .then(response => response.json())
                .then(data => {
                    console.log("ATM marked as robbed:", data);
                })
                .catch(error => {
                    console.error('Error marking ATM as robbed:', error);
                });
            },

            // Soyulmuş ATM'leri yükle
            loadRobbedATMs() {
                const saved = localStorage.getItem('robbedATMs');
                this.robbedATMs = saved ? JSON.parse(saved) : {};
            },

            // Bomb planting function
            plantBomb(vehicle) {
                if (!vehicle) return;

                this.addTerminalOutput(`${vehicle.name} (${vehicle.plate}) vehicle is being planted with a bomb...`, 'warning');
                this.forceTerminalScroll();

                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'plantBomb',
                        plate: vehicle.plate
                    })
                })
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'ok') {
                            this.addTerminalOutput(data.message || 'Bomb planted!', 'warning');

                            // Reset selected vehicle
                            this.selectedVehicle = null;

                            // Rescan nearby vehicles
                setTimeout(() => {
                                this.scanNearbyVehicles(false);
                            }, 1000);
                        } else {
                            this.addTerminalOutput(`Error: ${data.message || 'Bomb could not be planted.'}`, 'error');
                        }
                        this.forceTerminalScroll();
                    })
                    .catch(error => {
                        console.error('Error planting bomb:', error);
                        this.addTerminalOutput('An error occurred while planting the bomb.', 'error');
                        this.forceTerminalScroll();
                    });
            },

            // New function to detonate vehicle
            detonateVehicle: function(vehicle) {
                if (!vehicle || !vehicle.bombPlanted) return;
                
                this.addTerminalOutput(`Detonating explosive device on ${vehicle.name} (${vehicle.plate})...`, 'warning');
                
                // Trigger explosion on server
                    fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                        action: 'detonateVehicle',
                            plate: vehicle.plate
                        })
                })
                .then(response => response.json())
                .then(response => {
                    if (response.status === 'success') {
                        // Mark vehicle as destroyed in UI
                        this.$set(vehicle, 'isDestroyed', true);
                        this.$set(vehicle, 'bombPlanted', false);
                        
                        // Success message
                        this.addTerminalOutput(`${vehicle.name} (${vehicle.plate}) has been destroyed by remote detonation.`, 'success');
                        
                        // If this was the selected vehicle, clear selection
                        if (this.selectedVehicle && this.selectedVehicle.id === vehicle.id) {
                            this.selectedVehicle = null;
                            this.showDoorControls = false;
                        }
                    } else {
                        this.addTerminalOutput(`Detonation failed: ${response.message || 'Vehicle not found'}`, 'error');
                    }
                })
                .catch(error => {
                    console.error('Detonation error:', error);
                    this.addTerminalOutput(`Detonation failed: Network error`, 'error');
                });
            },

            // Update the ATM hack initiation function
            hackATM(atm) {
                if (!atm) return;

                // If a robbery is already in progress, stop the operation
                if (this.isHacking) {
                    this.addTerminalOutput('An operation is already in progress!', 'error');
                    this.forceTerminalScroll();
                    return;
                }

                this.isHacking = true;
                this.hackProgress = 0;
                this.addTerminalOutput(`Initiating robbery on ATM #${atm.id}...`, 'warning');
                this.forceTerminalScroll();

                // Start the robbery process
                this.robATM(atm);
            },

            // ATM robbery process
            robATM(atm) {
                // Soygun süresi ve kazanılacak para miktarı
                const hackDuration = 30000; // 30 saniye
                const updateInterval = 500; // 500ms'de bir güncelleme
                const totalUpdates = hackDuration / updateInterval;
                const moneyPerUpdate = 10; // Her güncelleme başına 10$ ekle
                let totalMoney = 0;
                let progress = 0;
                
                // Prop aşamaları
                const propStages = [
                    { progress: 25, count: 4, message: 'Initial cash bundles are falling!' },
                    { progress: 50, count: 7, message: 'More cash is dropping!' },
                    { progress: 75, count: 10, message: 'Cash rain has begun!' },
                    { progress: 100, count: 15, message: 'Robbery complete! Huge cash rain!' }
                ];
                
                const completedStages = {};
                
                // İlerleme çubuğunu sıfırla
                this.hackProgress = 0;
                this.transferAmount = 0;
                this.remainingLoot = atm.loot || 50000;
                this.updateProgressBar(0);
                
                // Soygun işlemi için bir interval başlat
                const hackInterval = setInterval(() => {
                    // İlerlemeyi güncelle
                    progress += (100 / totalUpdates);
                    progress = Math.min(progress, 100);
                    
                    // Para miktarını güncelle
                    totalMoney += moneyPerUpdate;
                    
                    // İlerleme değerlerini güncelle
                    this.hackProgress = progress;
                    this.transferAmount = Math.floor((progress / 100) * (atm.loot || 50000));
                    this.remainingLoot = Math.floor((atm.loot || 50000) * (1 - progress / 100));
                    
                    // İlerleme çubuğunu güncelle
                    this.updateProgressBar(progress);
                    
                    // Terminal çıktısını güncelle
                    if (Math.floor(progress) % 10 === 0) {
                        this.addTerminalOutput(`ATM #${atm.id} robbery in progress: ${Math.floor(progress)}%`, 'info');
                        this.forceTerminalScroll();
                    }
                    
                    // Prop aşamalarını kontrol et
                    propStages.forEach(stage => {
                        if (progress >= stage.progress && !completedStages[stage.progress]) {
                            completedStages[stage.progress] = true;
                            this.addTerminalOutput(stage.message, 'success');
                            this.forceTerminalScroll();
                            
                            // Para proplarını oluştur
                            fetch(`https://${GetParentResourceName()}/createMoneyPropBurst`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json'
                                },
                                body: JSON.stringify({
                                    atmId: atm.id,
                                    count: stage.count
                                })
                            });
                        }
                    });
                    
                    // Soygun tamamlandı mı kontrol et
                    if (progress >= 100) {
                        clearInterval(hackInterval);
                        this.isHacking = false;
                        
                        // Soygun tamamlandı, parayı gönder
                        this.completeATMRobbery(atm, Math.floor(totalMoney));
                    }
                }, updateInterval);

                // Terminal çıktısı ekle
                this.addTerminalOutput(`Initiating ATM robbery at ${atm.location}...`, 'info');
                this.addTerminalOutput(`Estimated loot: $${this.formatMoney(atm.loot)}`, 'info');
                
                // İlerleme çubuğu ekle
                this.terminalOutput.push({
                    type: 'system',
                    isProgressBar: true,
                    text: `[${
                        '░'.repeat(40)}] 0%\nTransfer: $0 | Remaining: $${this.formatMoney(atm.loot)}`
                });
                
                // Kaydırma işlemini zorla
                this.$nextTick(() => {
                    this.forceTerminalScroll();
                });
            },

            // Send the money when the robbery is complete
            completeATMRobbery(atm, amount) {
                // İlerleme çubuğunu %100 olarak güncelle
                this.hackProgress = 100;
                this.transferAmount = amount;
                this.remainingLoot = 0;
                this.updateProgressBar(100);
                
                this.addTerminalOutput(`ATM #${atm.id} robbery completed! Earned: $${amount}`, 'success');
                this.forceTerminalScroll();
                
                // ATM'yi soyulmuş olarak işaretle
                this.markATMAsRobbed(atm.id);
                
                // Sunucuya para miktarını gönder
                fetch(`https://${GetParentResourceName()}/atmRobComplete`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        amount: amount,
                        atmId: atm.id
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        this.addTerminalOutput(data.message || 'Money added to your account!', 'success');
                    } else {
                        this.addTerminalOutput(data.message || 'Error occurred during money transfer!', 'error');
                    }
                    this.forceTerminalScroll();
                })
                .catch(error => {
                    console.error('Error sending robbery data:', error);
                    this.addTerminalOutput('Error occurred during money transfer!', 'error');
                    this.forceTerminalScroll();
                });
                
                // Başarı mesajını göster
                this.showHackCompleteMessage(amount);
                
                // 5 saniye sonra ilerleme çubuğunu gizle
                setTimeout(() => {
                    this.hackProgress = 0;
                }, 5000);
            },

            // Araç kapılarını açıp kapatma
            toggleDoor(vehicle, doorIndex) {
                if (!vehicle) return;
                
                // Kapı durumunu kontrol et ve tersine çevir
                const currentState = this.getDoorStatus(vehicle, doorIndex);
                const doorNames = ['Front Left', 'Front Right', 'Rear Left', 'Rear Right', 'Hood', 'Trunk'];
                
                // Terminal mesajı - işlem başlangıcı
                this.addTerminalOutput(`${currentState ? 'Closing' : 'Opening'} ${doorNames[doorIndex]} door on ${vehicle.name}...`, 'system');
                
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'door',
                        plate: vehicle.plate,
                        doorIndex: doorIndex,
                        state: !currentState
                    })
                })
                .then(response => response.json())
                .then(response => {
                    if (response.status === 'success') {
                        // Kapı durumunu güncelle
                        if (!vehicle.doors) {
                            this.$set(vehicle, 'doors', {});
                        }
                        this.$set(vehicle.doors, doorIndex, !currentState);
                        
                        // Terminal mesajı - işlem sonucu
                        const action = !currentState ? 'opened' : 'closed';
                        this.addTerminalOutput(`${doorNames[doorIndex]} door ${action} on ${vehicle.name} (${vehicle.plate})`, 'success');
                    }
                })
                .catch(error => {
                    console.error('Door control error:', error);
                    this.addTerminalOutput(`Failed to control door: ${error.message || 'Network error'}`, 'error');
                });
            },

            // Kapı durumunu kontrol et
            getDoorStatus(vehicle, doorIndex) {
                if (!vehicle || !vehicle.doors) return false;
                return vehicle.doors[doorIndex] || false;
            },

            // Tüm kapıları açıp kapatma
            toggleVehicleDoors(vehicle) {
                if (!vehicle) return;
                
                // Mevcut durumu kontrol et
                const doorsOpen = vehicle.doorsOpen || false;
                
                // Terminal mesajı - işlem başlangıcı
                this.addTerminalOutput(`${doorsOpen ? 'Closing' : 'Opening'} all doors on ${vehicle.name} (${vehicle.plate})...`, 'system');
                
                // Kapı durumunu güncelle (önce UI'ı güncelle)
                this.$set(vehicle, 'doorsOpen', !doorsOpen);
                
                // Tüm kapıları aç veya kapat
                const doorPromises = [];
                for (let i = 0; i < 6; i++) {
                    const promise = fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            action: 'door',
                            plate: vehicle.plate,
                            doorIndex: i,
                            state: !doorsOpen
                        })
                    })
                    .then(response => response.json())
                    .catch(error => {
                        console.error(`Door ${i} control error:`, error);
                        return { status: 'error' };
                    });
                    
                    doorPromises.push(promise);
                }
                
                // Tüm kapı işlemleri tamamlandığında
                Promise.all(doorPromises)
                    .then(results => {
                        const successCount = results.filter(r => r.status === 'success').length;
                        
                        if (successCount > 0) {
                            // Kapı durumlarını güncelle
                            if (!vehicle.doors) {
                                this.$set(vehicle, 'doors', {});
                            }
                            
                            for (let i = 0; i < 6; i++) {
                                this.$set(vehicle.doors, i, !doorsOpen);
                            }
                            
                            // Terminal mesajı - işlem sonucu
                            const actionDone = !doorsOpen ? 'opened' : 'closed';
                            this.addTerminalOutput(`All doors ${actionDone} on ${vehicle.name} (${vehicle.plate})`, 'success');
                        } else {
                            // Hata durumunda UI'ı eski haline getir
                            this.$set(vehicle, 'doorsOpen', doorsOpen);
                            this.addTerminalOutput(`Failed to control doors on ${vehicle.name}`, 'error');
                        }
                    });
            },

            // Araç kilidini açıp kapatma
            toggleVehicleLock(vehicle) {
                if (!vehicle) return;
                
                const action = vehicle.status === 'Locked' ? 'unlock' : 'lock';
                
                // Terminal mesajı - işlem başlangıcı
                this.addTerminalOutput(`${action === 'lock' ? 'Locking' : 'Unlocking'} ${vehicle.name} (${vehicle.plate})...`, 'system');
                
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: action,
                        plate: vehicle.plate
                    })
                })
                .then(response => response.json())
                .then(response => {
                    if (response.status === 'ok') {
                        // Araç durumunu güncelle
                        this.$set(vehicle, 'status', action === 'lock' ? 'Locked' : 'Unlocked');
                        
                        // Terminal mesajı - işlem sonucu
                        this.addTerminalOutput(`Vehicle ${action === 'lock' ? 'locked' : 'unlocked'}: ${vehicle.name} (${vehicle.plate})`, 'success');
                    }
                })
                .catch(error => {
                    console.error('Lock control error:', error);
                    this.addTerminalOutput(`Failed to ${action} vehicle: ${error.message || 'Network error'}`, 'error');
                });
            },

            // Araç konumunu haritada işaretle
            markVehicleLocation(vehicle) {
                if (!vehicle) return;
                
                // Eğer bu araç zaten işaretlenmişse, işaretleyiciyi kaldır
                if (this.markedVehicle === vehicle.plate) {
                    fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            action: 'markLocation',
                            remove: true
                        })
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'removed') {
                            this.markedVehicle = null;
                            this.addTerminalOutput(`${vehicle.name} (${vehicle.plate}) için harita işaretleyicisi kaldırıldı.`, 'info');
                            this.forceTerminalScroll();
                        }
                    })
                    .catch(error => {
                        console.error('Error removing vehicle marker:', error);
                        this.addTerminalOutput('İşaretleyici kaldırılırken hata oluştu.', 'error');
                        this.forceTerminalScroll();
                    });
                    
                    return;
                }
                
                // Önce aracın konumunu al
                fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: 'getVehicleLocation',
                        plate: vehicle.plate
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Konum alındı, şimdi haritada işaretle
                        fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({
                                action: 'markLocation',
                                coords: data.coords
                            })
                        })
                        .then(response => response.json())
                        .then(markerData => {
                            if (markerData.status === 'marked') {
                                this.markedVehicle = vehicle.plate;
                                this.addTerminalOutput(`${vehicle.name} (${vehicle.plate}) konumu haritada işaretlendi: ${data.location}`, 'success');
                                this.forceTerminalScroll();
                            } else {
                                this.addTerminalOutput(`Hata: ${markerData.message || 'Bilinmeyen bir hata oluştu.'}`, 'error');
                                this.forceTerminalScroll();
                            }
                        });
                    } else {
                        this.addTerminalOutput('Araç konumu alınamadı.', 'error');
                        this.forceTerminalScroll();
                    }
                })
                .catch(error => {
                    console.error('Error getting vehicle location:', error);
                    this.addTerminalOutput('Araç konumu alınırken hata oluştu.', 'error');
                    this.forceTerminalScroll();
                });
            },

            // Kapı kontrol panelini göster/gizle
            toggleDoorControls(vehicle) {
                if (!vehicle) return;
                
                // Durumu değiştir
                this.showDoorControls = !this.showDoorControls;
                
                // Eğer panel açıldıysa, kapı durumlarını güncelle
                if (this.showDoorControls) {
                    // Kapı durumlarını kontrol et
                    fetch(`https://${GetParentResourceName()}/vehicleAction`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            action: 'getDoorStatuses',
                            plate: vehicle.plate
                        })
                    })
                    .then(response => response.json())
                    .then(response => {
                        if (response.status === 'success') {
                            // Kapı durumlarını güncelle
                            if (!vehicle.doors) {
                                this.$set(vehicle, 'doors', {});
                            }
                            
                            for (let i = 0; i < 6; i++) {
                                this.$set(vehicle.doors, i, response.doorStatuses[i] || false);
                            }
                        }
                    })
                    .catch(error => {
                        console.error('Door status check error:', error);
                    });
                }
            },

            // Para prop'larını temizleme fonksiyonu
            clearMoneyProps(markerId) {
                // Bu fonksiyon client tarafında çalıştığı için NUI üzerinden çağrı yapıyoruz
                fetch(`https://${GetParentResourceName()}/clearMoneyProps`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        markerId: markerId
                    })
                })
                .then(response => {
                    if (!response.ok) {
                        this.addTerminalOutput(`Para propları temizlenirken hata: ${response.status}`, 'error');
                    }
                })
                .catch(error => {
                    this.addTerminalOutput(`Para propları temizlenirken hata: ${error.message}`, 'error');
                });
            },

            // Tekli para prop'u oluşturma
            createMoneyPropAtATM(atmId, coords) {
                fetch(`https://${GetParentResourceName()}/createMoneyProp`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        atmId: atmId,
                        coords: coords
                    })
                });
            },

            // Çoklu para prop'u patlaması (soygun tamamlandığında)
            createMoneyPropBurst(atmId) {
                fetch(`https://${GetParentResourceName()}/createMoneyPropBurst`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        atmId: atmId
                    })
                });
            },

            updateProgressBar(progress, transferAmount, remainingLoot) {
                if (!this.isHackingATM || !this.nearestATM) return;
                
                // İlerleme çubuğunu güncelle
                const progressBarWidth = Math.floor(progress * 40 / 100);
                const progressBar = '█'.repeat(progressBarWidth) + '░'.repeat(40 - progressBarWidth);
                
                // Terminal çıktısını güncelle
                for (let i = 0; i < this.terminalOutput.length; i++) {
                    if (this.terminalOutput[i].isProgressBar) {
                        this.terminalOutput[i].text = `[${progressBar}] ${Math.floor(progress)}%\nTransfer: $${this.formatMoney(transferAmount)} | Remaining: $${this.formatMoney(remainingLoot)}`;
                        this.forceTerminalScroll();
                        break;
                    }
                }
            },

            // Yeni fonksiyon ekleyin
            applyCustomWallpaper() {
                if (this.customWallpaperUrl && this.customWallpaperUrl.trim() !== '') {
                    // Özel URL'yi hem currentWallpaper hem de phoneSettings.wallpaper'a ayarla
                    this.currentWallpaper = this.customWallpaperUrl;
                    this.$set(this.phoneSettings, 'wallpaper', this.customWallpaperUrl);
                    
                    // Ayarları localStorage'a kaydet
                    localStorage.setItem('hackphone_wallpaper', this.customWallpaperUrl);
                    this.saveSettings();
                    
                    // Input alanını temizle
                    this.customWallpaperUrl = '';
                    
                    // Modalı kapat
                    this.showCustomWallpaperModal = false;
                } else {
                    // Boş URL gelirse varsayılan arka planı kullan
                    this.currentWallpaper = this.defaultWallpaper;
                    this.$set(this.phoneSettings, 'wallpaper', this.defaultWallpaper);
                    localStorage.setItem('hackphone_wallpaper', this.defaultWallpaper);
                    this.saveSettings();
                }
            },

            // Yeni fonksiyon ekleyin
            cancelCustomWallpaper() {
                this.showCustomWallpaperModal = false;
            },
        },

        watch: {
            // Track all phoneSettings properties
            'phoneSettings': {
                handler(newVal) {
                    this.saveSettings();
                },
                deep: true // Track all sub-properties
            },

            // Track VPN settings
            vpnActive() {
                this.saveSettings();
            },
            selectedVpnServer() {
                this.saveSettings();
            },

            // Track other settings
            activeSettingsTab() {
                this.saveSettings();
            },
            customColor() {
                this.saveSettings();
            },
            rgbValues: {
                handler() {
                    this.saveSettings();
                },
                deep: true
            },
            openSubSettings() {
                this.saveSettings();
            },

            // Terminal mesajları değiştiğinde otomatik kaydırma
            terminalOutput: {
                handler() {
                    // Terminal çıktısı değiştiğinde otomatik kaydırma
                    this.forceTerminalScroll();
                },
                deep: true
            }
        },

        mounted() {
            this.loadSettings();
            this.updateBatteryLevel();
            this.loadLanguagePreference();
            
            // Saat güncelleme
            this.updateServerTime();
            
            // Terminal setup
            this.initializeTerminalOutput();
            
            // Sadece telefon aktifken keydown eventini dinle
            document.addEventListener("keydown", this.onKeydown);
            
            window.addEventListener('message', this.handleEventMessage);
        },
        
        beforeDestroy() {
            // Component yok edilmeden önce event listener'ları temizle
            document.removeEventListener("keydown", this.onKeydown);
            window.removeEventListener('message', this.handleEventMessage);
            
            // Zamanlayıcıları durdur
            this.stopVPNTimers();
            this.stopGPSTracking();
            
            // Diğer zamanlayıcıları temizle
            if (this.atmCheckInterval) {
                clearInterval(this.atmCheckInterval);
            }
        },

        created() {
            this.loadSettings();
            this.updateServerTime();
            window.addEventListener('message', this.handleEventMessage);
            document.addEventListener("keydown", this.onKeydown);
            this.loadRobbedATMs(); // Soyulmuş ATM'leri yükle
        }
    });
});

// Vue direktifi oluştur
Vue.directive('auto-scroll', {
    inserted: function(el) {
        setTimeout(() => {
            el.scrollTop = el.scrollHeight;
        }, 50);
    },
    update: function(el) {
        setTimeout(() => {
            el.scrollTop = el.scrollHeight;
        }, 50);
    },
    componentUpdated: function(el) {
        setTimeout(() => {
            el.scrollTop = el.scrollHeight;
        }, 50);
    }
});
