import requests
import json
from typing import Dict, List, Optional
import time
from dataclasses import dataclass
import random

@dataclass
class SATQuestion:
    id: str
    difficulty: int  # 1-3
    domain: str
    skill: str
    question_text: Optional[str] = None
    options: Optional[List[str]] = None
    correct_answer: Optional[str] = None
    explanation: Optional[str] = None

class SATQuestionScraper:
    BASE_URL = "https://satsuitequestionbank.collegeboard.org"
    
    def __init__(self):
        self.session = requests.Session()
        # Set common headers that mimic a real browser
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'Sec-Ch-Ua': '"Chromium";v="122", "Not(A:Brand";v="24", "Google Chrome";v="122"',
            'Sec-Ch-Ua-Mobile': '?0',
            'Sec-Ch-Ua-Platform': '"macOS"',
            'Upgrade-Insecure-Requests': '1'
        })

    def _init_session(self):
        """Initialize session by visiting the main page first."""
        try:
            print("Initializing session...")
            # Visit the main page first
            response = self.session.get(
                f"{self.BASE_URL}/questionbank",
                allow_redirects=True
            )
            response.raise_for_status()
            
            print(f"Initial page status code: {response.status_code}")
            print(f"Initial page cookies: {dict(response.cookies)}")
            print(f"Initial page headers: {dict(response.headers)}")
            
            # Update headers for subsequent requests
            self.session.headers.update({
                'Accept': 'application/json, text/plain, */*',
                'Referer': f"{self.BASE_URL}/questionbank",
                'Sec-Fetch-Dest': 'empty',
                'Sec-Fetch-Mode': 'cors',
                'Sec-Fetch-Site': 'same-origin',
                'X-Requested-With': 'XMLHttpRequest'
            })
            
            return True
        except requests.RequestException as e:
            print(f"Error initializing session: {str(e)}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"Response status: {e.response.status_code}")
                print(f"Response headers: {dict(e.response.headers)}")
                print(f"Response content: {e.response.text}")
            return False

    def get_questions_list(self, page: int = 1, per_page: int = 20) -> List[SATQuestion]:
        """Fetch list of questions from the question bank."""
        try:
            # Initialize session if needed
            if page == 1:
                if not self._init_session():
                    return []

            # Add a random delay between requests (1-3 seconds)
            time.sleep(random.uniform(1, 3))
            
            url = f"{self.BASE_URL}/api/questionbank/questions"
            params = {
                "page": page,
                "limit": per_page,
                "subject": "math",
                "type": "multiple-choice"
            }
            
            print(f"\nMaking request to: {url}")
            print(f"With params: {params}")
            print(f"Using headers: {dict(self.session.headers)}")
            
            response = self.session.get(url, params=params)
            
            print(f"Response status: {response.status_code}")
            print(f"Response headers: {dict(response.headers)}")
            print(f"Response content: {response.text[:500]}...")  # Print first 500 chars
            
            response.raise_for_status()
            
            data = response.json()
            questions = []
            
            for q in data.get('items', []):
                # Map difficulty levels to numbers
                difficulty_map = {'easy': 1, 'medium': 2, 'hard': 3}
                difficulty = difficulty_map.get(q.get('difficulty', 'medium'), 2)
                
                question = SATQuestion(
                    id=q.get('id', ''),
                    difficulty=difficulty,
                    domain=q.get('domain', ''),
                    skill=q.get('skill', '')
                )
                questions.append(question)
            
            return questions
            
        except requests.RequestException as e:
            print(f"Error fetching questions list: {str(e)}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"Response status: {e.response.status_code}")
                print(f"Response headers: {dict(e.response.headers)}")
                print(f"Response content: {e.response.text}")
            return []

    def get_question_details(self, question_id: str) -> Optional[Dict]:
        """Fetch detailed information for a specific question."""
        try:
            response = self.session.get(f"{self.BASE_URL}/api/questionbank/questions/{question_id}")
            response.raise_for_status()
            
            data = response.json()
            return data
            
        except requests.RequestException as e:
            print(f"Error fetching question {question_id}: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"Response status: {e.response.status_code}")
                print(f"Response headers: {dict(e.response.headers)}")
                print(f"Response content: {e.response.text}")
            return None

    def scrape_all_questions(self, max_pages: int = None) -> List[SATQuestion]:
        """Scrape all questions with pagination."""
        all_questions = []
        page = 1
        
        while True:
            print(f"Fetching page {page}...")
            questions = self.get_questions_list(page=page)
            
            if not questions:
                break
                
            all_questions.extend(questions)
            
            # Optional page limit
            if max_pages and page >= max_pages:
                break
                
            page += 1
        
        return all_questions

    def save_questions_to_file(self, questions: List[SATQuestion], filename: str = "sat_questions.json"):
        """Save scraped questions to a JSON file."""
        data = [vars(q) for q in questions]
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"Saved {len(questions)} questions to {filename}")

def main():
    scraper = SATQuestionScraper()
    
    # Example: Scrape first 3 pages
    questions = scraper.scrape_all_questions(max_pages=3)
    
    # Save to file
    scraper.save_questions_to_file(questions)
    
    # Print summary
    print(f"\nScraped {len(questions)} questions")
    domains = set(q.domain for q in questions)
    print(f"Domains: {domains}")
    
if __name__ == "__main__":
    main() 