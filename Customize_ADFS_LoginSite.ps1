
Set-AdfsProperties -EnableIdPInitiatedSignonPage $true

Set-AdfsGlobalAuthenticationPolicy -EnablePaginatedAuthenticationPages $true

Set-AdfsGlobalAuthenticationPolicy -AllowAdditionalAuthenticationAsPrimary $true

Get-AdfsWebConfig

Export-AdfsWebTheme -Name DefaultAdfs2019 -DirectoryPath C:\Custom_theme

New-AdfsWebTheme –Name CustomAdfsTheme –SourceName DefaultAdfs2019


Set-AdfsWebTheme -TargetName CustomAdfsTheme -AdditionalFileResource @{Uri=”/adfs/portal/images/custom/Background_login_blue.png”;path=”C:\Custom_theme\images\Custom\Background_login_blue.png”}

Set-AdfsWebTheme -TargetName CustomAdfsTheme -Illustration @{path=”C:\Custom_theme\images\custom\Background_login_blue.png”}


Set-AdfsWebConfig -ActiveThemeName CustomAdfsTheme

Set-AdfsWebTheme -TargetName CustomAdfsTheme -Logo @{path="C:\Custom_theme\images\custom\Logo_Full_4.png"}

Set-AdfsWebTheme –TargetName CustomAdfsTheme –StyleSheet @{path="C:\Custom_theme\css\Custom\style.css"}

Set-AdfsProperties -EnableKmsi $true
