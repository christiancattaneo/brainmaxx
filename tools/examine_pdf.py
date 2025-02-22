from PyPDF2 import PdfReader

def examine_pdf():
    pdf_path = '/Users/christiancattaneo/Downloads/SAT Question Bank PDFs/Updated Files/Math/Algebra/Linear Equations in One Variable/Linear Equations in One Variable 1.pdf'
    reader = PdfReader(pdf_path)
    
    # Print first page content
    text = reader.pages[0].extract_text()
    print("First 1000 characters of content:")
    print("-" * 80)
    print(text[:1000])
    print("-" * 80)
    print(f"\nTotal pages: {len(reader.pages)}")

if __name__ == "__main__":
    examine_pdf() 