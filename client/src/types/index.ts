export interface ReviewSource {
  product_name: string;
  rating: number;
  author: string;
  content: string;
}

export interface RAGResponse {
  answer: string;
  sources: ReviewSource[];
  product_id?: number;
}

export interface RAGState {
  question: string;
  response: RAGResponse | null;
  loading: boolean;
  error: string | null;
}