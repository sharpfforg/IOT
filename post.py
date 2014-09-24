// IOT network data

import httplib
import os

#http://api.yeelink.net/v1.0/device/14437/sensor/24200/datapoints
#http://api.yeelink.net/v1.0/device/14437/sensor/24202/datapoints


API_KEY = 'f8926b9d9151f7d0210034a68b957227'
DEV_ID = '14437'
SEN_ID1 = '24200' #temprature
SEN_ID2 = '24202' #switcher
SEN_ID3 = '24241' #generic
SEN_ID4 = '24331' #graphic
SERVER = 'api.yeelink.net'


body1_post = '{"timestamp":"2014-09-23T16:35:14","value":2.34}'
body1_get = ''
body2_post = '{"value":1}'
body2_get = ''
body3_post = '{"key":"110adc3949ba59abbe56e037f20f884e","value":{"data1":"hello, world1!","data2":"hello, world2!"}}'
body3_get = ''
body4_post = ''

method = 'GET' #'POST' or 'GET'             ####

pic_path = '2.jpg'                          ####
fh = open(pic_path)
for line in fh.readlines(): 
    body4_post += line
fh.close()


body4_get_info_or_content = ''
body = body4_get_info_or_content                           ####
content_length = str(len(body))

SEN_ID = SEN_ID4                            ####

IF_PHOTO_NOT = '/datapoints'
IF_PHOTO_POST = '/photos' # '' or '/photos'
IF_PHOTO_INFO = '/photo/info'
IF_PHOTO_CONTENT = '/photo/content'
IF_PHOTO = IF_PHOTO_CONTENT                  ####


req = '/v1.0/device/' + DEV_ID + '/sensor/' + SEN_ID + IF_PHOTO \
    + ' HTTP/1.1\r\n' \
    + 'Host:' + SERVER + '\r\n' \
    + 'Accept: */*\r\n' \
    + 'U-ApiKey: ' + API_KEY + '\r\n' \
    + 'Content-Length: ' + content_length + '\r\n' \
    + 'Content-Type: application/x-www-form-urlencoded\r\n' \
    + 'Connection: close\r\n' \
    + '\r\n' \
    + body


conn = httplib.HTTPConnection(SERVER)    
conn.request(method, req)
r1 = conn.getresponse() 
#print r1.status, r1.reason
print r1.read()
