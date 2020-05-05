import requests
from bs4 import BeautifulSoup, SoupStrainer
import concurrent.futures
from flask import Flask, request
from flask import jsonify
from attendance import *

MAIN = {}

app = Flask(__name__)

def generate_course_links(request_object, huid, passw):
    course_links = []
    Only_parse = SoupStrainer('script', attrs={'language': 'JavaScript'})
    totalcourses_soup = BeautifulSoup(request_object, 'lxml', parse_only=Only_parse)

    for x in totalcourses_soup.find_all('script',language='JavaScript'):
        if 'var PFieldList_win4' in str(x):
            TOTAL_COURSES = str(x)
            break

    TOTAL_COURSES = int(TOTAL_COURSES[TOTAL_COURSES.find('DESCR1')+8:len(TOTAL_COURSES)-79])
    
    For_Codes = SoupStrainer('a',class_='PSHYPERLINK')
    code_soup = BeautifulSoup(request_object, 'lxml', parse_only=For_Codes)

    for link in range(TOTAL_COURSES):
        code = code_soup.find('a',class_='PSHYPERLINK',id='SELECT$'+str(link)).get_text()
        url = 'https://pscs.habib.edu.pk/psc/ps_4/EMPLOYEE/PSFT_HR/c/MANAGE_ACADEMIC_RECORDS.STDNT_ATTENDANCE.GBL?Page=STDNT_ATTND_SRCH&Action=U&ACAD_CAREER=UGRD&CLASS_NBR='+code+'&DESCR=HCPPALL&EMPLID='+huid[2:]+'&INSTITUTION=HUNIV&STRM=2011&TargetFrameName=None&&'
        course_links.append(url)
    
    return course_links

def Info_and_Courses(url, huid, passw):
    main_dict = {}

    login_data = {'userid':huid, 'pwd':passw}
    request_return = requests.post(url, data=login_data).text
    Parse_only = SoupStrainer(class_=['PSEDITBOX_DISPONLY'])
    name_soup = BeautifulSoup(request_return, 'lxml', parse_only=Parse_only)
    Name = name_soup.find('span',class_='PSEDITBOX_DISPONLY',id='PERSONAL_DTSAVW_NAME').get_text()
    main_dict['username'] = Name
    main_dict['id'] = huid
    links = generate_course_links(request_return, huid, passw)
    main_dict['coursedata'] = multithreading(links, huid, passw)

    return main_dict
    

@app.route("/")
def greetings():
    return "Hazir HU API"

@app.route("/login")
def login():
    
    ID = request.args.get('id')
    PASS = request.args.get('pwd')

    if isinstance(ID, str) == False or isinstance(PASS, str) == False:
        return jsonify(
            Error =  "001",
            Message = "Null ID or Password"
        )
        
    if ID[2:].isdigit() == False:
        return jsonify(
            Error =  "002",
            Message = "Incorrect ID"
        )

    URL = 'https://pscs.habib.edu.pk/psc/ps_4/EMPLOYEE/PSFT_HR/c/X_ATTEND_TRACKING.STDNT_ATTEND_TERM.GBL?Page=STDNT_ATTDNCE1&Action=U&EMPLID='+ID[2:]+'&INSTITUTION=HUNIV&STRM=2011&TargetFrameName=None'

    try:
        return_main = Info_and_Courses(URL, ID, PASS)
    except:
        return jsonify(error = '01', message = 'Login Failed')

    return jsonify(return_main)

if __name__ == '__main__':
    app.run(debug=True)
