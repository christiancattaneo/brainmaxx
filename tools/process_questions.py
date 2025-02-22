import json
import os
from pathlib import Path
import re

class QuestionProcessor:
    def __init__(self, digital_json_path, images_dir, output_dir):
        self.digital_json_path = digital_json_path
        self.images_dir = images_dir
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        
    def load_digital_questions(self):
        """Load questions from the digital JSON file."""
        with open(self.digital_json_path, 'r') as f:
            return json.load(f)
            
    def get_image_paths_for_question(self, question_id):
        """Find all images associated with a question ID."""
        image_files = []
        # Check both regular and full page images
        patterns = [
            f"{question_id}_img_*.png",
            f"{question_id}_full_page.png"
        ]
        
        for pattern in patterns:
            matches = list(Path(self.images_dir).glob(pattern))
            image_files.extend([str(path.relative_to(self.images_dir)) for path in matches])
            
        return sorted(image_files)
        
    def clean_math_text(self, text):
        """Clean up text while preserving MathML content."""
        if not text:
            return text
            
        # Remove HTML paragraph styling but keep the content
        text = text.replace('<p style="text-align: left;">', '')
        text = text.replace('</p>', '')
        
        # Clean up newlines and tabs in MathML to make it more compact
        def clean_mathml(match):
            mathml = match.group(0)
            # Remove newlines and tabs within MathML
            mathml = re.sub(r'[\n\t]', '', mathml)
            # Remove extra spaces between tags
            mathml = re.sub(r'>\s+<', '><', mathml)
            return mathml
            
        text = re.sub(r'<math[^>]*>.*?</math>', clean_mathml, text, flags=re.DOTALL)
        
        # Fix HTML entities outside of MathML
        text = text.replace('&rsquo;', "'")
        text = text.replace('&nbsp;', ' ')
        
        # Clean up extra whitespace
        text = ' '.join(text.split())
        
        return text.strip()
        
    def process_question(self, question_data):
        """Convert a question to our iOS-friendly format."""
        content = question_data.get('content', {})
        
        # Clean the content while preserving MathML
        stem = self.clean_math_text(content.get('stem', ''))
        rationale = self.clean_math_text(content.get('rationale', ''))
        
        return {
            "id": question_data.get('questionId'),
            "type": content.get('type'),
            "subject": question_data.get('module', '').capitalize(),
            "topic": question_data.get('primary_class_cd_desc'),
            "skill": question_data.get('skill_desc'),
            "difficulty": question_data.get('difficulty'),
            "question": {
                "text": stem,
                "original_math": stem,
                "options": content.get('answerOptions', []),
                "correct_answers": content.get('correct_answer', [])
            },
            "explanation": {
                "text": rationale,
                "original_math": rationale
            },
            "images": self.get_image_paths_for_question(question_data.get('questionId', ''))
        }
        
    def process_all_questions(self):
        """Process all questions and create organized output."""
        digital_questions = self.load_digital_questions()
        
        # Process questions and organize by subject/topic
        organized_data = {}
        
        for _, question_data in digital_questions.items():
            processed = self.process_question(question_data)
            
            subject = processed['subject']
            topic = processed['topic']
            
            # Create nested structure
            if subject not in organized_data:
                organized_data[subject] = {}
            if topic not in organized_data[subject]:
                organized_data[subject][topic] = []
                
            organized_data[subject][topic].append(processed)
            
        return organized_data
        
    def save_output(self, data):
        """Save processed questions to JSON files."""
        # Save one file per subject
        for subject, topics in data.items():
            filename = f"{subject.lower()}_questions.json"
            output_path = os.path.join(self.output_dir, filename)
            
            with open(output_path, 'w') as f:
                json.dump({
                    "subject": subject,
                    "topics": topics
                }, f, indent=2)
            print(f"Saved {output_path}")
            
        # Save a manifest file
        manifest = {
            "subjects": list(data.keys()),
            "total_questions": sum(
                len(questions) 
                for topics in data.values() 
                for questions in topics.values()
            )
        }
        
        manifest_path = os.path.join(self.output_dir, "questions_manifest.json")
        with open(manifest_path, 'w') as f:
            json.dump(manifest, f, indent=2)
        print(f"Saved {manifest_path}")

def main():
    # Paths
    digital_json = "/Users/christiancattaneo/Downloads/SAT Question Bank PDFs/cb-digital-questions.json"
    images_dir = "data/questions/images"
    output_dir = "data/processed_questions"
    
    # Process questions
    processor = QuestionProcessor(digital_json, images_dir, output_dir)
    data = processor.process_all_questions()
    processor.save_output(data)
    
if __name__ == "__main__":
    main() 