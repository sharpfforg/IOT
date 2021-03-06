# IOT network debug tool
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
SEN_ID5 = '24937' #ohm
SERVER = 'api.yeelink.net'


body1_post = '{"timestamp":"2014-09-23T16:35:14","value":2.34}'
body1_get = ''
body2_post = '{"value":1}'
body2_get = ''
body3_post = '{"key":"110adc3949ba59abbe56e037f20f884e","value":{"data1":"hello, world1!","data2":"hello, world2!"}}'
body3_get = ''
body4_post = ''

method = 'POST' #'POST' or 'GET'             ####


pic_path = '2.jpg'                          ####
if os.path.exists(pic_path):
    fh = open(pic_path, "r")
    for line in fh.readlines():
        body4_post += line
    fh.close()


body4_get_info_or_content = ''
<<<<<<< HEAD
body = body2_post                           ####
=======
body5_post = '{"timestamp":"2014-09-29T16:35:14","value":156.7}'
body5_get = ''
body = body4_get_info_or_content                           ####
>>>>>>> FETCH_HEAD
content_length = str(len(body))

SEN_ID = SEN_ID4                            ####

IF_PHOTO_NOT = '/datapoints'
IF_PHOTO_POST = '/photos' # '' or '/photos'
IF_PHOTO_INFO = '/photo/info'
IF_PHOTO_CONTENT = '/photo/content'
IF_PHOTO_CONTENT_SPEC = '/photo/content/2014-09-24T11:14:25'
IF_PHOTO = IF_PHOTO_NOT                     ####


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

history = '/v1.0/device/' + DEV_ID + '/sensor/' + SEN_ID + '.json?start=2010-09-01T14:01:46&end=2014-10-08T15:21:40&interval=1&page=1' \
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
conn.request(method, history)                       ####
r1 = conn.getresponse() 
#print r1.status, r1.reason
print r1.read()
