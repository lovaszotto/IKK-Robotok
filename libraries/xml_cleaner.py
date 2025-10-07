
import re

class XmlCleaner:
    def clean_xml(self, xml):
        """
        Remove non-printable/control characters from XML string.
        """
        return re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F\u00A0]', '', xml)

def get_keyword_names():
    return ['Clean Xml']

Clean_Xml = XmlCleaner().clean_xml
