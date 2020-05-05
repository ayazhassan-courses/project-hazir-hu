import requests
from bs4 import BeautifulSoup, SoupStrainer
import concurrent.futures


def attendance_table(asoup, table_rows):

    status = ""
    reason = ""
    present = 0
    absent = 0
    percentage = 0

    if (
        asoup.find(
            "span", class_="PSEDITBOX_DISPONLY", id="PSXLATITEM_XLATSHORTNAME$18$$0"
        ).get_text()
        == "Dropped"
    ):
        return "Dropped"

    code = asoup.find(
        "span", class_="PSEDITBOX_DISPONLY", id="STDNT_ATND_SRCH_CLASS_NBR"
    ).get_text()
    course_name = asoup.find(
        "span", class_="PSEDITBOX_DISPONLY", id="CLASS_TBL_VW_DESCR"
    ).get_text()
    course_code = (
        asoup.find(
            "span", class_="PSEDITBOX_DISPONLY", id="STDNT_ATND_SRCH_SUBJECT"
        ).get_text()
        + asoup.find(
            "span", class_="PSEDITBOX_DISPONLY", id="STDNT_ATND_SRCH_CATALOG_NBR$0"
        ).get_text()
    )
    course_component = asoup.find(
        "span", class_="PSEDITBOX_DISPONLY", id="PSXLATITEM_XLATSHORTNAME"
    ).get_text()
    course_section = asoup.find(
        "span", class_="PSEDITBOX_DISPONLY", id="STDNT_ATND_SRCH_CLASS_SECTION$0"
    ).get_text()


    Attendance_Table = {}

    Attendance_Table["totalclasses"] = table_rows
    Attendance = []

    for row in range(table_rows):
        Single_Attendance = {}

        if (
            asoup.find(
                "span",
                class_="PSEDITBOX_DISPONLY",
                id="CLASS_ATTENDNCE_CLASS_ATTEND_DT$" + str(row),
            )
            is not None
        ):

            Single_Attendance["Date"] = asoup.find(
                "span",
                class_="PSEDITBOX_DISPONLY",
                id="CLASS_ATTENDNCE_CLASS_ATTEND_DT$" + str(row),
            ).get_text()

        if (
            asoup.find(
                "input",
                class_="PSCHECKBOX",
                id="CLASS_ATTENDNCE_ATTEND_PRESENT$" + str(row),
            )
            is not None
        ):
            status = str(
                asoup.find(
                    "input",
                    class_="PSCHECKBOX",
                    id="CLASS_ATTENDNCE_ATTEND_PRESENT$" + str(row),
                )
            )[16:23]

        if (
            asoup.find(
                "span",
                class_="PSDROPDOWNLIST_DISPONLY",
                id="CLASS_ATTENDNCE_ATTEND_REASON$" + str(row),
            )
            is not None
        ):
            reason = asoup.find(
                "span",
                class_="PSDROPDOWNLIST_DISPONLY",
                id="CLASS_ATTENDNCE_ATTEND_REASON$" + str(row),
            ).get_text()

        if status == "CHECKBO" and (reason == "Upd by AE" or reason == "Manually"):
            Single_Attendance["Status"] = "Absent"
            absent += 1
        elif status == "checked" and (reason == "Upd by AE" or reason == "Manually"):
            Single_Attendance["Status"] = "Present"
            present += 1
        elif status == "CHECKBO":
            Single_Attendance["Status"] = "Not Updated"

        Attendance.append(Single_Attendance)
        del Single_Attendance

    total_classes = present + absent
    percentage = (present / total_classes) * 100
    Attendance_Table["totalclasses"] = total_classes
    Attendance_Table["presentclasses"] = present
    Attendance_Table["absentclasses"] = absent
    Attendance_Table["attendancepercentage"] = percentage
    Attendance_Table["classcode"] = code
    Attendance_Table["attendances"] = Attendance
    Attendance_Table["coursename"] = course_name
    Attendance_Table["coursecode"] = course_code
    Attendance_Table["classcode"] = code
    Attendance_Table["coursecomponent"] = course_component
    Attendance_Table["coursesection"] = course_section
    Attendance_Table["attendances"] = Attendance
    return Attendance_Table


def scrap_it(url_huid_passw):
    url, huid, passw = url_huid_passw[0], url_huid_passw[1], url_huid_passw[2]

    login_data = {"userid": huid, "pwd": passw}
    for_row = SoupStrainer("script", attrs={"language": "JavaScript"})
    only_these = SoupStrainer(
        class_=["PSDROPDOWNLIST_DISPONLY", "PSCHECKBOX", "PSEDITBOX_DISPONLY",]
    )
    request_return = requests.post(url, data=login_data).text
    row_soup = BeautifulSoup(request_return, "lxml", parse_only=for_row)

    # finding total classes in semester
    for x in row_soup.find_all("script", language="JavaScript"):
        if "var PFieldList_win4" in str(x):
            total_rows = str(x)
            break
    total_rows = int(
        total_rows[total_rows.find("CLASS_ATTENDNCE_CLASS_ATTEND_TYPE") + 35 : -13]
    )

    soup = BeautifulSoup(request_return, "lxml", parse_only=only_these)
    table = attendance_table(soup, total_rows)
    return table


def multithreading(links, huid, passw):
    links = tuple((link, huid, passw) for link in links)
    COURSE_DATA = []

    with concurrent.futures.ThreadPoolExecutor(max_workers=len(links)) as executor:

        for each in executor.map(scrap_it, links):
            COURSE_DATA.append(each)

    return COURSE_DATA
