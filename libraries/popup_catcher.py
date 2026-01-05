import threading
import time
from selenium.webdriver.common.by import By
from robot.api import logger

class PopupCatcher:
                                    # 'Folytatás' gomb keresése aria-label alapján és kattintása
                                    folytatas_aria_buttons = driver.find_elements(By.XPATH, "//button[contains(@aria-label, 'Folytatás') and contains(@class, 'button')]")
                                    for btn in folytatas_aria_buttons:
                                        if btn.is_displayed() and btn.is_enabled():
                                            logger.info("PopupCatcher: 'Folytatás' aria-label gombot találtam, kattintok!")
                                            btn.click()
                                            logger.info("PopupCatcher: 'Folytatás' aria-label gomb kattintva.")
                    # FOLYTATÁS gomb keresése és kattintása
                    folytatas_buttons = driver.find_elements(By.XPATH, "//div[contains(@class, 'mat-dialog-container')]//button[contains(., 'FOLYTATÁS')]")
                    for btn in folytatas_buttons:
                        if btn.is_displayed() and btn.is_enabled():
                            logger.info("PopupCatcher: 'FOLYTATÁS' gombot találtam, kattintok!")
                            btn.click()
                            logger.info("PopupCatcher: 'FOLYTATÁS' gomb kattintva.")
    def __init__(self, seleniumlib):
        self.seleniumlib = seleniumlib
        self.running = False
        self.thread = None

    def start_popup_watcher(self, interval=1):
        if self.running:
            return
                try:
                    # Ellenőrizzük, hogy van-e aktív böngésző
                    driver = getattr(self.seleniumlib, 'driver', None)
                    if not driver:
                        time.sleep(interval)
                        pass
                    # Először próbáljuk eltüntetni az overlay-t, ha van
                    overlays = driver.find_elements(By.CSS_SELECTOR, ".cdk-overlay-backdrop.cdk-overlay-dark-backdrop.cdk-overlay-backdrop-showing")
                    for overlay in overlays:
                        if overlay.is_displayed():
                            try:
                                overlay.click()
                                logger.info("PopupCatcher: Overlay-t kattintottam, hogy eltűnjön.")
                            except Exception as e:
                                logger.warn(f"PopupCatcher: Overlay kattintás hiba: {e}")
                    # 'Folytatás' gomb keresése aria-label alapján és kattintása
                    folytatas_aria_buttons = driver.find_elements(By.XPATH, "//button[contains(@aria-label, 'Folytatás') and contains(@class, 'button')]")
                    for btn in folytatas_aria_buttons:
                        if btn.is_displayed() and btn.is_enabled():
                            logger.info("PopupCatcher: 'Folytatás' aria-label gombot találtam, kattintok!")
                            btn.click()
                            logger.info("PopupCatcher: 'Folytatás' aria-label gomb kattintva.")
                    # FOLYTATÁS gomb keresése és kattintása
                    folytatas_buttons = driver.find_elements(By.XPATH, "//div[contains(@class, 'mat-dialog-container')]//button[contains(., 'FOLYTATÁS')]")
                    for btn in folytatas_buttons:
                        if btn.is_displayed() and btn.is_enabled():
                            logger.info("PopupCatcher: 'FOLYTATÁS' gombot találtam, kattintok!")
                            btn.click()
                            logger.info("PopupCatcher: 'FOLYTATÁS' gomb kattintva.")
                    # Modal ablakban lévő gombok
                    buttons = driver.find_elements(By.XPATH, "//div[contains(@class, 'mat-dialog-container')]//button")
                    for btn in buttons:
                        if btn.is_displayed() and btn.is_enabled():
                            logger.info("PopupCatcher: Bezárandó ablakot találtam, gombot kattintok!")
                            btn.click()
                            logger.info("PopupCatcher: Modal button clicked.")
                    # Bezáró ikonok (pl. X gomb)
                    close_icons = driver.find_elements(By.XPATH, "//div[contains(@class, 'mat-dialog-container')]//*[contains(@class, 'close') or contains(@class, 'mat-dialog-close') or contains(@class, 'cdk-overlay-close')]")
                    for icon in close_icons:
                        if icon.is_displayed() and icon.is_enabled():
                            logger.info("PopupCatcher: Modal ablak bezáró ikont találtam, kattintok!")
                            icon.click()
                            logger.info("PopupCatcher: Modal close icon clicked.")
                except Exception as e:
                    logger.warn(f"PopupCatcher error: {e}")
                time.sleep(interval)
from robot.api.deco import keyword
from robot.api.deco import keyword, library

@library
class PopupCatcherLibrary:
    def __init__(self):
        self._catcher = None

    @keyword("Start Popup Catcher")
    def start_popup_catcher(self):
        from SeleniumLibrary import SeleniumLibrary
        seleniumlib = SeleniumLibrary()
        self._catcher = PopupCatcher(seleniumlib)
        self._catcher.start_popup_watcher()

    @keyword("Stop Popup Catcher")
    def stop_popup_catcher(self):
        if self._catcher:
            self._catcher.stop_popup_watcher()
