CREATE TABLE "Користувач" (
    "id_користувача" SERIAL PRIMARY KEY,
    "ім’я" VARCHAR(100) NOT NULL
        CHECK ("ім’я" ~ '^[А-Яа-яІіЇїЄєҐґA-Za-z\\- ]+$'),
    "вік" INT CHECK ("вік" >= 0),
    "електроннаПошта" VARCHAR(150) UNIQUE NOT NULL
        CHECK ("електроннаПошта" ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
);

CREATE TABLE "ПрофільКористувача" (
    "id_профілю" SERIAL PRIMARY KEY,
    "id_користувача" INT NOT NULL UNIQUE
        REFERENCES "Користувач"("id_користувача") ON DELETE CASCADE,
    "датаСтворення" DATE NOT NULL,
    "статусАктивності" VARCHAR(10) NOT NULL
        CHECK ("статусАктивності" IN ('active','inactive'))
);

CREATE TABLE "ІсторіяПоказників" (
    "id_історії" SERIAL PRIMARY KEY,
    "id_профілю" INT NOT NULL
        REFERENCES "ПрофільКористувача"("id_профілю") ON DELETE CASCADE,
    "дата" DATE NOT NULL
);

CREATE TABLE "Сенсор" (
    "id_сенсора" SERIAL PRIMARY KEY,
    "тип" VARCHAR(50) NOT NULL,
    "модель" VARCHAR(100),
    "одиницяВиміру" VARCHAR(50)
);

CREATE TABLE "ЖиттєвийПараметр" (
    "id_параметра" SERIAL PRIMARY KEY,
    "назва" VARCHAR(50) NOT NULL,
    "значення" REAL NOT NULL,
    "часВимірювання" TIMESTAMP NOT NULL,
    "id_історії" INT NOT NULL
        REFERENCES "ІсторіяПоказників"("id_історії") ON DELETE CASCADE,
    "id_сенсора" INT NOT NULL
        REFERENCES "Сенсор"("id_сенсора")
);

CREATE TABLE "СеансПрактики" (
    "id_сеансу" SERIAL PRIMARY KEY,
    "датаПочатку" TIMESTAMP NOT NULL,
    "тривалість" INT CHECK ("тривалість" > 0),
    "id_профілю" INT NOT NULL
        REFERENCES "ПрофільКористувача"("id_профілю") ON DELETE CASCADE
);

CREATE TABLE "Аудіозапис" (
    "id_аудіо" SERIAL PRIMARY KEY,
    "назваФайлу" VARCHAR(200) NOT NULL,
    "тривалість" REAL CHECK ("тривалість" > 0),
    "шляхДоФайлу" VARCHAR(300) NOT NULL,
    "id_сеансу" INT NOT NULL
        REFERENCES "СеансПрактики"("id_сеансу") ON DELETE CASCADE
);

CREATE TABLE "АналізІнтонації" (
    "id_аналізу" SERIAL PRIMARY KEY,
    "точність" REAL CHECK ("точність" BETWEEN 0 AND 100),
    "стабільність" REAL CHECK ("стабільність" BETWEEN 0 AND 100),
    "ритм" REAL CHECK ("ритм" BETWEEN 0 AND 100),
    "id_аудіо" INT NOT NULL UNIQUE
        REFERENCES "Аудіозапис"("id_аудіо") ON DELETE CASCADE
);

CREATE TABLE "ВізуальнийФідбек" (
    "id_фідбеку" SERIAL PRIMARY KEY,
    "типГрафіки" VARCHAR(50) NOT NULL,
    "оновленняУЧасі" INT CHECK ("оновленняУЧасі" > 0),
    "id_аналізу" INT NOT NULL UNIQUE
        REFERENCES "АналізІнтонації"("id_аналізу") ON DELETE CASCADE,
    "id_профілю" INT NOT NULL
        REFERENCES "ПрофільКористувача"("id_профілю") ON DELETE CASCADE
);

CREATE TABLE "Рекомендація" (
    "id_рекомендації" SERIAL PRIMARY KEY,
    "текст" TEXT NOT NULL,
    "датаФормування" DATE NOT NULL,
    "id_профілю" INT NOT NULL
        REFERENCES "ПрофільКористувача"("id_профілю") ON DELETE CASCADE,
    "id_параметра" INT
        REFERENCES "ЖиттєвийПараметр"("id_параметра") ON DELETE SET NULL,
    "id_аналізу" INT
        REFERENCES "АналізІнтонації"("id_аналізу") ON DELETE SET NULL,
    CHECK ( ("id_параметра" IS NOT NULL) OR ("id_аналізу" IS NOT NULL) )
);

CREATE INDEX "idx_history_profile_date" ON "ІсторіяПоказників"("id_профілю","дата");
CREATE INDEX "idx_param_history" ON "ЖиттєвийПараметр"("id_історії");
CREATE INDEX "idx_param_sensor" ON "ЖиттєвийПараметр"("id_сенсора");
CREATE INDEX "idx_audio_session" ON "Аудіозапис"("id_сеансу");
CREATE INDEX "idx_analysis_audio" ON "АналізІнтонації"("id_аудіо");
CREATE INDEX "idx_feedback_profile" ON "ВізуальнийФідбек"("id_профілю");
CREATE INDEX "idx_recommendation_profile" ON "Рекомендація"("id_профілю");
