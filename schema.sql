-- 啟用外鍵約束
PRAGMA foreign_keys = ON;

-- ====================================================
-- 1. 使用者資料表 (Users)
-- ====================================================
CREATE TABLE IF NOT EXISTS Users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    nickname TEXT,
    bio TEXT,
    fav_book TEXT,
    quote TEXT,
    avatar_url TEXT
);

-- ====================================================
-- 2. 我的書庫資料表 (Library)
-- ====================================================
CREATE TABLE IF NOT EXISTS Library (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    author TEXT,
    genre TEXT,
    review TEXT,
    best_quote TEXT,
    cover_img_url TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- ====================================================
-- 3. 好書推薦資料表 (Recommendations)
-- ====================================================
CREATE TABLE IF NOT EXISTS Recommendations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    author TEXT,
    added_by INTEGER NOT NULL,
    FOREIGN KEY (added_by) REFERENCES Users(id) ON DELETE SET NULL
);

-- ====================================================
-- 4. 推薦投票紀錄表 (Recommendation_Votes)
-- ====================================================
CREATE TABLE IF NOT EXISTS Recommendation_Votes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rec_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (rec_id) REFERENCES Recommendations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    UNIQUE(rec_id, user_id)
);

-- ====================================================
-- 5. 【全新第一層】書籍主表 (Books)
-- 依需求：完全不紀錄是誰新增了那本書，也不紀錄時間
-- ====================================================
CREATE TABLE IF NOT EXISTS Books (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    author TEXT,
    UNIQUE(title, author) -- 避免重複建立相同書名與作者的書
);

-- ====================================================
-- 6. 【全新第二層】書籍討論區 - 觀點表 (Discussions)
-- 透過 book_id 關聯主書，一本書下面可以有多個討論點
-- ====================================================
CREATE TABLE IF NOT EXISTS Discussions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER NOT NULL,          -- 核心：串接 Books 表的 ID
    user_id INTEGER NOT NULL,          -- 紀錄是誰發起了這個討論觀點
    title TEXT,                        -- 保留此欄位以相容舊資料遷移
    author TEXT,                       -- 保留此欄位以相容舊資料遷移
    viewpoint TEXT NOT NULL,           -- 討論核心觀點
    created_at TEXT,                   -- 觀點發布時間
    FOREIGN KEY (book_id) REFERENCES Books(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- ====================================================
-- 7. 【全新第三層】書籍討論區 - 留言表 (Comments)
-- 依需求：留言區必須精準紀錄時間跟發文的人
-- ====================================================
CREATE TABLE IF NOT EXISTS Comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    discussion_id INTEGER NOT NULL,    -- 核心：串接 Discussions 表的 ID
    user_id INTEGER NOT NULL,          -- 紀錄留言的人
    content TEXT NOT NULL,             -- 留言內容
    created_at TEXT,                   -- 紀錄留言精準時間
    FOREIGN KEY (discussion_id) REFERENCES Discussions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);