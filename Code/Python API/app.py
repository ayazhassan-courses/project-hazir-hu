from bs4 import BeautifulSoup
import requests
from flask import Flask, request
from flask import jsonify

COURSES, SOAPS = {}, {}
ID, PASS, Name, Main_Soap = '','','',''
KEYS = []
TOTAL_COURSES = 0


app = Flask(__name__)

def scrap_it(ur, huid, passw):
    login_data = {'userid':huid, 'pwd':passw}
    s = requests.session()
    soup = BeautifulSoup(s.post(ur, data=login_data).text, 'lxml')
    return soup
    

def courselist(ms):
    global COURSES, KEYS, ID, TOTAL_COURSES
    
    for x in ms.find_all('script',language='JavaScript'):
        if 'var PFieldList_win4' in x.get_text():
            TOTAL_COURSES = x.get_text()
            break

    TOTAL_COURSES = (TOTAL_COURSES[TOTAL_COURSES.find('DESCR1')+8:65])

    if ']' in TOTAL_COURSES:
        TOTAL_COURSES = TOTAL_COURSES[:-1]
    TOTAL_COURSES = int(TOTAL_COURSES)

    for x in range(TOTAL_COURSES):
        KEYS.append('C'+str(x))
        COURSES['C'+str(x)] = {'name' : ms.find('span',class_='PSEDITBOX_DISPONLY',id='DESCR1$'+str(x)).get_text(),
                                'subject' : ms.find('span',class_='PSEDITBOX_DISPONLY',id='SUBJECT$'+str(x)).get_text(),
                                'code' : ms.find('a',class_='PSHYPERLINK',id='SELECT$'+str(x)).get_text()}
    
def remove_dropped(y):
    global COURSES, KEYS, ID, PASS, SOAPS, TOTAL_COURSES

    
    cnum = COURSES['C'+str(y)]['code']
    url = 'https://pscs.habib.edu.pk/psc/ps_4/EMPLOYEE/PSFT_HR/c/MANAGE_ACADEMIC_RECORDS.STDNT_ATTENDANCE.GBL?Page=STDNT_ATTND_SRCH&Action=U&ACAD_CAREER=UGRD&CLASS_NBR='+cnum+'&DESCR=HCPPALL&EMPLID='+ID[2:]+'&INSTITUTION=HUNIV&STRM=2011&TargetFrameName=None&&'                           
    soup = scrap_it(url, ID, PASS)
    
    if soup.find('span',class_='PSEDITBOX_DISPONLY', id ='PSXLATITEM_XLATSHORTNAME$18$$0').get_text() == 'Dropped':
        COURSES.pop('C'+str(y))
        KEYS.remove('C'+str(y))
    else: 
        SOAPS['C'+str(y)] = soup
        COURSES['C'+str(y)]['component'] = soup.find('span',class_='PSEDITBOX_DISPONLY',id='PSXLATITEM_XLATSHORTNAME').get_text()


def attendance_table(asoup):
    Attendance_Table = {}
    status = ''
    reason = ''
    present = 0
    absent = 0
    percentage = 0
    
    for x in asoup.find_all('script',language='JavaScript'):
        if 'var PFieldList_win4' in x.get_text():
            table_rows = x.get_text()
            break
    table_rows = int(table_rows[table_rows.find('CLASS_ATTENDNCE_CLASS_ATTEND_TYPE')+35:-4])
    
    Attendance_Table[101] = table_rows
    
    for row in range(table_rows):
        Attendance_Table[row+1] = {}
        
        if asoup.find('span',class_='PSEDITBOX_DISPONLY',id='CLASS_ATTENDNCE_CLASS_ATTEND_DT$'+str(row)) is not None:
            Attendance_Table[row+1]['Date'] = (asoup.find('span',class_='PSEDITBOX_DISPONLY',id='CLASS_ATTENDNCE_CLASS_ATTEND_DT$'+str(row)).get_text())
        
        if asoup.find('input',class_='PSCHECKBOX',id='CLASS_ATTENDNCE_ATTEND_PRESENT$'+str(row)) is not None:
            status = str(asoup.find('input',class_='PSCHECKBOX',id='CLASS_ATTENDNCE_ATTEND_PRESENT$'+str(row)))[16:23]

        if asoup.find('span',class_='PSDROPDOWNLIST_DISPONLY',id='CLASS_ATTENDNCE_ATTEND_REASON$'+str(row)) is not None:
            reason = (asoup.find('span',class_='PSDROPDOWNLIST_DISPONLY',id='CLASS_ATTENDNCE_ATTEND_REASON$'+str(row)).get_text())

        if status == 'CHECKBO' and (reason == 'Upd by AE' or reason == 'Manually'):
            Attendance_Table[row+1]['Status'] = 'Absent'
            absent += 1
        elif status == 'checked' and (reason == 'Upd by AE' or reason == 'Manually'):
            Attendance_Table[row+1]['Status'] = 'Present'
            present += 1
        elif status == 'CHECKBO':
            Attendance_Table[row+1]['Status'] = 'Not Updated'

    total_classes = present + absent
    percentage = (present/total_classes)*100
    Attendance_Table[102] = total_classes
    Attendance_Table[103] = present
    Attendance_Table[104] = absent
    Attendance_Table[105] = percentage
    

    return Attendance_Table


@app.route("/")
def greetings():
    return "Welome to Hazir HU App"


@app.route("/flogin")
def login():
    global ID, PASS, Name, Main_Soap

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
        Main_Soap = scrap_it(URL, ID, PASS)
    except:
        return jsonify(error = '01', message = 'Login Failed')

    Name = Main_Soap.find('span',class_='PSEDITBOX_DISPONLY',id='PERSONAL_DTSAVW_NAME').get_text()

    return jsonify(
        name = Name,
        id = ID
    )
    
@app.route('/allcourses')   
def course_data():
    global ID, PASS, COURSES, KEYS, Main_Soap, TOTAL_COURSES
    Id = request.args.get('id')
    pwd = request.args.get('pwd')

    if Id != ID or pwd != PASS:
        return jsonify(error = '00', message = 'Incorrect Credentials')

    try:
        courselist(Main_Soap)
    except:
        return jsonify(error = '02', message = 'Course Load Failed')

    return jsonify(
        total = TOTAL_COURSES,
        courses = COURSES
        )


@app.route('/removedropped')   
def removing_dropped():
    global ID, PASS, COURSES, KEYS, Main_Soap
    Id = request.args.get('id')
    pwd = request.args.get('pwd')
    Y = request.args.get('C')
    
    try:
        remove_dropped(Y)
        return jsonify(COURSES)
    except:
        return jsonify(error = '03', message = 'Course Removal Failed')




@app.route('/haziri')
def Hazir():
    global ID, PASS, COURSES, KEYS

    Id = request.args.get('id')
    pwd = request.args.get('pwd')
    C = request.args.get('C')
    htable = {}

    if Id != ID or pwd != PASS:
        return jsonify(error = '00', message = 'Incorrect Credentials')

    print (KEYS)
    for k in range(len(KEYS)):
        if KEYS[k] == 'C'+C:
            s = SOAPS[KEYS[k]]
            htable = attendance_table(s)
            break

    if htable:
        return jsonify(htable)

    return jsonify(
        Error = '04',
        Message = 'Course does not exists'
    )


if __name__ == '__main__':
    app.run(debug=True)
