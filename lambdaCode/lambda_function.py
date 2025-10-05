import json
import os
import urllib.parse
import boto3
from io import BytesIO, StringIO
import pandas as pd
import traceback

result_bucket = os.environ.get('RESULT_BUCKET_NAME', '')

def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    print(f"Bucket name: {bucket_name}")
    print(f"Object key: {object_key}")
    s3 = boto3.client('s3')
    try:
        obj = s3.get_object(Bucket=bucket_name, Key=object_key)
        print("Students information downloaded succesfully")
        csv_content = obj['Body'].read().decode('utf-8-sig')
        csv_file_like_object = StringIO(csv_content)
        students_info = pd.read_csv(csv_file_like_object, header=0, sep=',')
        students_info["final_grade"] = 0.25 * students_info["first_grade"] + 0.25 * students_info["second_grade"] + 0.25 * students_info["third_grade"] + 0.25 * students_info["fourth_grade"]
        students_info["final_grade"] = round(students_info["final_grade"], 2)
        students_info["pass"] = students_info["final_grade"] >= 6.0
        students_info["bmi"] = students_info["weight"] / students_info["height"]**2
        students_info["bmi"] = round(students_info["bmi"], 2)
        csv_buffer = BytesIO()
        students_info.to_csv(csv_buffer, index=False, encoding='utf-8')
        csv_buffer.seek(0)
        s3.put_object(
            Bucket=result_bucket,
            Key='SalidaEjercicio5.csv',
            Body=csv_buffer.getvalue(),
            ContentType="text/csv; charset=utf-8",
        )
        print("Students information processed succesfully")
        return {
            'statusCode': 200,
            'body': json.dumps('Students information processed succesfully')
        }
    except Exception as e:
        print(f"Error processing students file: {str(e)}")
        print(str(traceback.format_exc()))
        return {
            'statusCode': 500,
            'body': json.dumps(str(traceback.format_exc()))
        }
