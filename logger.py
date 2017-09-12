#!/usr/bin/python
# pip arptable

from selenium import webdriver
from python_arptable import ARPTABLE
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support import expected_conditions as EC
import socket, platform, sys, python_arptable, random, string, time

with open ("Mac.txt", "r") as myfile:
	spoofed_mac = myfile.read().replace(":","%3A").strip()
	
#prelimenary vars

ap_mac = ARPTABLE[0]["HW address"].replace(":","%3A").strip()
first_name = "".join(random.choice(string.ascii_lowercase)for i in range(random.randrange(3,7)))
last_name = "".join(random.choice(string.ascii_lowercase)for i in range(random.randrange(5,10)))
email_string = str(random.randrange(1000000000,9999999999)) + "@comcast.com"
zip_code_int = random.randrange(10000,99999)
os = platform.system()
unq_hostname = "".join(random.choice(string.ascii_uppercase + string.ascii_lowercase +
									 string.digits + '-') for i in range(random.randrange(9,15)))
url_wifiondemand = "https://wifiondemand.xfinity.com/wod/landing?c=n&macId=" + \
				   spoofed_mac + "&a=as&bn=st22&location=default&apMacId=" + \
				   ap_mac + "&issuer=r&deviceModel=" + os + "+Firefox+-+" + \
				   os + "&deviceName=" + unq_hostname

profile = webdriver.FirefoxProfile()
profile.set_preference( "reader.parse-on-load.enabled" , False )
profile.set_preference("permissions.default.stylesheet", 2);
profile.set_preference("permissions.default.image", 2);
profile.set_preference("javascript.enabled", False);
driver = webdriver.Firefox(profile)
wait = WebDriverWait(driver,300)
	   
#first page
driver.get(url_wifiondemand)

free_opt = wait.until(EC.presence_of_element_located((By.XPATH,"//*[contains(text(), 'Complimentary')]")))
first_submit = wait.until(EC.presence_of_element_located((By.ID,"continueButton")))

free_opt.click();
first_submit.click();

#second page

first_name_box = wait.until(EC.presence_of_element_located((By.XPATH,"//input[@placeholder='First Name']")))
last_name_box = driver.find_element_by_xpath("//input[@placeholder='Last Name']")
email_box = driver.find_element_by_xpath("//input[@placeholder='Email']")
zip_code_box = driver.find_element_by_xpath("//input[@placeholder='Zip Code']")

first_name_box.send_keys(first_name)
last_name_box.send_keys(last_name)
email_box.send_keys(email_string)
zip_code_box.send_keys(zip_code_int)
zip_code_box.send_keys(Keys.TAB)

wait.until(EC.element_to_be_clickable((By.XPATH,"//*[contains(text(), 'Continue')]"))).click()

#third page

username = wait.until(EC.element_to_be_clickable((By.XPATH,"//button[@id='usePersonalEmail']")))
password = wait.until(EC.presence_of_element_located((By.XPATH,"//input[@id='password']")))
password_retype = wait.until(EC.presence_of_element_located((By.XPATH,"//input[@id='passwordRetype']")))
drop_menu = wait.until(EC.presence_of_element_located((By.ID,"dk0-combobox")))
secret_answer = wait.until(EC.presence_of_element_located((By.ID,"secretAnswer")))
terms_checkbox = wait.until(EC.presence_of_element_located((By.ID,"cimTcAccepted")))
third_submit = wait.until(EC.element_to_be_clickable((By.ID,"submitButton")))

username.send_keys(Keys.ENTER)
password.send_keys(unq_hostname + "$")
password_retype.send_keys(unq_hostname + "$")
drop_menu.send_keys(Keys.ENTER)
drop_menu.click()
drop_menu.send_keys(Keys.ARROW_DOWN)
drop_menu.send_keys(Keys.ENTER)
secret_answer.send_keys(unq_hostname)
terms_checkbox.click()
third_submit.send_keys(Keys.ENTER)

#final page

wait.until(EC.presence_of_element_located((By.XPATH,"//*[@id='APP']/div/div[3]/div/div/div[1]/div/div[2]/div/div/div[2]/div/button"))).click()
time.sleep(3)
driver.quit()
