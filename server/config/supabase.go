package config

import (
	"os"
	"github.com/joho/godotenv"
)

func init() {
	// Загрузка переменных окружения из .env файла
	if err := godotenv.Load(); err != nil {
		panic("Error loading .env file")
	}
}

// GetSupabaseConfig возвращает конфигурацию Supabase
func GetSupabaseConfig() (string, string, string) {
	return os.Getenv("SUPABASE_URL"),
		os.Getenv("SUPABASE_ANON_KEY"),
		os.Getenv("SUPABASE_SERVICE_ROLE_KEY")
}

// GetDBConfig возвращает конфигурацию базы данных
func GetDBConfig() string {
	return "host=" + os.Getenv("DB_HOST") +
		" user=" + os.Getenv("DB_USER") +
		" password=" + os.Getenv("DB_PASSWORD") +
		" dbname=" + os.Getenv("DB_NAME") +
		" port=5432" +
		" sslmode=require"
}
