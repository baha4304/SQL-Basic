CREATE DATABASE shop_db;

USE shop_db;


-- member 테이블 생성
CREATE TABLE member (
  member_id CHAR(8) NOT NULL,
  member_name CHAR(5) NOT NULL,
  member_addr CHAR(20),
  PRIMARY KEY (member_id),
  KEY idx_member_name (member_name)
);


-- product 테이블 생성
CREATE TABLE product (
  product_name CHAR(4) NOT NULL,
  cost INT NOT NULL,
  make_date DATE,
  company CHAR(5),
  amount INT NOT NULL,
  PRIMARY KEY (product_name)
);


-- member 데이터 삽입
INSERT INTO member (member_id, member_name, member_addr) VALUES
('hero', '임영웅', '서울 은평구'),
('iyou', '아이유', '인천 남구'),
('jyp', '박진영', '경기 고양시'),
('tess', '나훈아', '경기 부천시');


-- product 데이터 삽입
INSERT INTO product (product_name, cost, make_date, company, amount) VALUES
('바나나', 1500, '2021-07-01', '델몬트', 17),
('삼각김밥', 800, '2023-09-01', 'CJ', 22),
('카스', 2500, '2022-03-01', 'OB', 3);


-- view 생성
CREATE VIEW member_view AS
SELECT member_id, member_name, member_addr
FROM member;
