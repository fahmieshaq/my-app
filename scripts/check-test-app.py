from pathlib import Path
root = Path(__file__).resolve().parents[1]
required = ['pom.xml','Dockerfile','src/main/java/com/example/smoketest/SmokeTestApplication.java',
            'src/main/java/com/example/smoketest/HelloController.java',
            'src/test/java/com/example/smoketest/HelloControllerTest.java',
            'src/main/resources/application.properties']
missing = [f for f in required if not (root/f).is_file()]
print('PASS: source structure' if not missing else 'FAIL: missing '+', '.join(missing))
print('PENDING: Maven build, Docker build, GitHub OIDC, Terraform, staging and production deploys')
raise SystemExit(bool(missing))
