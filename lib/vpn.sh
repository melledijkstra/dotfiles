#!/bin/bash

# VPN Config
VPN_COMMAND="/opt/cisco/secureclient/bin/vpn"
VPN_APP="Cisco Secure Client"
VPN_PROFILE="EMEA Herzo - adidas"

vpn_connect() {
    echo "   Triggering VPN: $VPN_PROFILE..."
    osascript <<EOF
# Ensure the app is running
tell application "$VPN_APP"
    if not running then
        launch
        delay 2
    end if
    activate
    reopen # Force the main window to show if it's hidden
end tell

tell application "System Events"
    # Wait for the process
    set timeoutCounter to 0
    repeat until (exists process "$VPN_APP") or (timeoutCounter > 20)
        delay 0.5
        set timeoutCounter to timeoutCounter + 1
    end repeat

    if exists (process "$VPN_APP") then
        tell process "$VPN_APP"
            # Wait for the specific window
            set timeoutCounter to 0
            repeat until (exists window "Cisco Secure Client") or (timeoutCounter > 20)
                delay 0.5
                set timeoutCounter to timeoutCounter + 1
            end repeat

            if exists (window "Cisco Secure Client") then
                set vpnWindow to window "Cisco Secure Client"

                # Wait for the Connect button specifically
                set timeoutCounter to 0
                repeat until (exists button "Connect" of vpnWindow) or (timeoutCounter > 10)
                    delay 0.5
                    set timeoutCounter to timeoutCounter + 1
                end repeat

                # Select the profile if combo box exists
                if (exists combo box 1 of vpnWindow) then
                    set value of combo box 1 of vpnWindow to "$VPN_PROFILE"
                end if

                # Click Connect
                if (exists button "Connect" of vpnWindow) then
                    perform action "AXPress" of button "Connect" of vpnWindow
                    return "Connected triggered"
                else
                    return "Connect button not found"
                end if
            else
                return "Window not found"
            end if
        end tell
    else
        return "Process not found"
    end if
end tell
EOF
}

vpn_disconnect() {
    echo "   Disconnecting VPN..."
    $VPN_COMMAND disconnect
#     osascript <<EOF
# tell application "System Events"
#     if exists (process "$VPN_APP") then
#         tell process "$VPN_APP"
#             if (exists window "Cisco Secure Client") then
#                 set vpnWindow to window "Cisco Secure Client"
#                 if (exists button "Disconnect" of vpnWindow) then
#                     click button "Disconnect" of vpnWindow
#                     delay 1
#                 end if
#             end if
#         end tell
#     end if
# end tell
# EOF
}
