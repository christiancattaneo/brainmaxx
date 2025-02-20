import os
import json
import fitz  # PyMuPDF
import re
from pathlib import Path

class SATQuestionParser:
    def __init__(self, pdf_path, output_dir):
        self.pdf_path = pdf_path
        self.output_dir = output_dir
        self.image_dir = os.path.join(output_dir, "images")
        os.makedirs(self.image_dir, exist_ok=True)
        
    def clean_text(self, text):
        """Clean up text by removing extra whitespace and normalizing characters."""
        text = re.sub(r'\s+', ' ', text)
        text = text.replace('\ufb03', 'ffi')
        text = text.replace('\u00a0', ' ')
        return text.strip()
        
    def extract_images_from_page(self, page, question_id):
        """Extract images from a PDF page and save them."""
        image_files = []
        
        # First try to extract images directly
        image_list = page.get_images()
        for img_index, img in enumerate(image_list, start=1):
            try:
                xref = img[0]
                base_image = page.parent.extract_image(xref)
                
                if base_image:
                    image_data = base_image["image"]
                    image_ext = base_image["ext"]
                    
                    # Create filename
                    image_filename = f"{question_id}_img_{img_index}.{image_ext}"
                    image_path = os.path.join(self.image_dir, image_filename)
                    
                    # Save image
                    with open(image_path, "wb") as f:
                        f.write(image_data)
                    
                    # Store relative path
                    image_files.append(image_filename)
                    print(f"Saved image: {image_filename}")
            
            except Exception as e:
                print(f"Error extracting image {img_index}: {str(e)}")
                continue
        
        # If no images found or they're too small, try extracting as PNG
        if not image_files or os.path.getsize(os.path.join(self.image_dir, image_files[0])) < 1000:
            try:
                # Convert page to PNG image
                pix = page.get_pixmap(matrix=fitz.Matrix(2, 2))  # 2x zoom for better quality
                
                # Save as PNG
                image_filename = f"{question_id}_full_page.png"
                image_path = os.path.join(self.image_dir, image_filename)
                pix.save(image_path)
                
                # Store relative path
                image_files = [image_filename]
                print(f"Saved full page image: {image_filename}")
                
            except Exception as e:
                print(f"Error extracting full page image: {str(e)}")
        
        return image_files
    
    def parse_question_and_answer(self, text, images):
        """Parse a question and its answer from text."""
        try:
            # Extract question ID
            id_match = re.search(r'ID:\s*(\w+)', text)
            if not id_match:
                return None
            question_id = id_match.group(1)
            
            # Split into question and answer sections
            parts = text.split("Answer")
            if len(parts) < 2:
                return None
                
            question_part = parts[0]
            answer_part = "Answer" + parts[1]
            
            # Extract question text
            question_text = re.search(r'ID:.*?\n(.*?)(?=A\.)', question_part, re.DOTALL)
            if not question_text:
                return None
            question_text = self.clean_text(question_text.group(1))
            
            # Extract options
            options = []
            option_matches = re.findall(r'([A-D])\.\s*([^A-D.]+)(?=[A-D]\.|$)', question_part)
            for _, option_text in option_matches:
                option = self.clean_text(option_text)
                if option:
                    options.append(option)
                    
            # Extract correct answer
            correct_match = re.search(r'Correct Answer:\s*([A-D])', answer_part)
            correct_answer = correct_match.group(1) if correct_match else None
            
            # Extract rationale
            rationale_match = re.search(r'Rationale\s*(.*?)(?=Question Difficulty|$)', answer_part, re.DOTALL)
            rationale = self.clean_text(rationale_match.group(1)) if rationale_match else None
            
            # Extract difficulty
            difficulty_match = re.search(r'Question Difficulty:\s*(\w+)', answer_part)
            difficulty = difficulty_match.group(1) if difficulty_match else "Unknown"
            
            return {
                "id": question_id,
                "text": question_text,
                "options": options,
                "images": images,
                "correct_answer": correct_answer,
                "rationale": rationale,
                "difficulty": difficulty
            }
            
        except Exception as e:
            print(f"Error parsing question: {str(e)}")
            return None
    
    def process_pdf(self):
        """Process the PDF and extract all questions."""
        output_data = {
            "questions": []
        }
        
        try:
            doc = fitz.open(self.pdf_path)
            
            # Process each page
            for page_num, page in enumerate(doc):
                print(f"\nProcessing page {page_num + 1}...")
                
                # Get text
                text = page.get_text()
                
                # Get question ID for images
                id_match = re.search(r'ID:\s*(\w+)', text)
                if not id_match:
                    continue
                question_id = id_match.group(1)
                
                # Extract images
                images = self.extract_images_from_page(page, question_id)
                
                # Parse question and answer
                question = self.parse_question_and_answer(text, images)
                if question:
                    output_data["questions"].append(question)
                    print(f"Successfully parsed question {question['id']} with {len(question['images'])} images")
                else:
                    print(f"Failed to parse question from page {page_num + 1}")
                    
            doc.close()
            
        except Exception as e:
            print(f"Error processing PDF: {str(e)}")
            
        return output_data
    
    def save_json(self, data, filename="sat_questions.json"):
        """Save parsed data to JSON file."""
        output_path = os.path.join(self.output_dir, filename)
        with open(output_path, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"\nSaved {len(data['questions'])} questions to {output_path}")

def main():
    pdf_path = "SAT Suite Question Bank - Results.pdf"
    output_dir = "data/questions"
    
    parser = SATQuestionParser(pdf_path, output_dir)
    data = parser.process_pdf()
    parser.save_json(data)

if __name__ == "__main__":
    main() 