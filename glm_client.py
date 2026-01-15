"""
GLM 4.7 API 연결 클라이언트
Zhipu AI의 GLM 모델을 사용하는 간단한 예제
"""

from zhipuai import ZhipuAI
import os


def chat_with_glm(message: str, api_key: str = None) -> str:
    """GLM 4.7 모델과 대화"""

    # API 키 설정 (환경변수 또는 직접 전달)
    api_key = api_key or os.getenv("ZHIPUAI_API_KEY")

    if not api_key:
        raise ValueError("API 키가 필요합니다. ZHIPUAI_API_KEY 환경변수를 설정하세요.")

    client = ZhipuAI(api_key=api_key)

    response = client.chat.completions.create(
        model="glm-4",  # GLM-4 모델 사용
        messages=[
            {"role": "user", "content": message}
        ]
    )

    return response.choices[0].message.content


def main():
    # 사용 예제
    question = "안녕하세요! 간단히 자기소개 해주세요."

    try:
        answer = chat_with_glm(question)
        print(f"질문: {question}")
        print(f"답변: {answer}")
    except Exception as e:
        print(f"오류 발생: {e}")


if __name__ == "__main__":
    main()
