import crypto from 'crypto';
import { promisify } from 'util';

class CryptoUtils {
    static KEY_LENGTH = 32;
    static SALT_LENGTH = 16;
    static ITERATIONS = 100000;
    static IV_LENGTH = 16;
    static DIGEST = 'sha256';
    static ALGORITHM = 'aes-256-cbc';

    /**
     * Encrypts a password
     * @param {string} password - The password to encrypt
     * @param {string} secretKey - The secret key to use for encryption
     * @returns {Promise<string>} The encrypted password
     */
    static async encrypt(password, secretKey) {
        if (!password || !secretKey) {
            throw new Error('Password and secret key are required');
        }

        try {
            const iv = crypto.randomBytes(this.IV_LENGTH);
            const salt = crypto.randomBytes(this.SALT_LENGTH);
            
            const pbkdf2Promise = promisify(crypto.pbkdf2);
            const key = await pbkdf2Promise(
                secretKey,
                salt,
                this.ITERATIONS,
                this.KEY_LENGTH,
                this.DIGEST
            );

            const cipher = crypto.createCipheriv(this.ALGORITHM, key, iv);
            let encrypted = cipher.update(password, 'utf8', 'hex');
            encrypted += cipher.final('hex');

            // Combine IV, salt, and encrypted data with : as delimiter
            return `${iv.toString('hex')}:${salt.toString('hex')}:${encrypted}`;
        } catch (error) {
            throw new Error(`Encryption failed: ${error.message}`);
        }
    }

    /**
     * Decrypts an encrypted password
     * @param {string} encryptedData - The encrypted password
     * @param {string} secretKey - The secret key used for encryption
     * @returns {Promise<string>} The decrypted password
     */
    static async decrypt(encryptedData, secretKey) {
        if (!encryptedData || !secretKey) {
            throw new Error('Encrypted data and secret key are required');
        }

        console.log(encryptedData);


        try {
            const parts = encryptedData.split(':');
            if (parts.length !== 3) {
                throw new Error('Invalid encrypted data format');
            }

            const [ivHex, saltHex, encrypted] = parts;
            const iv = Buffer.from(ivHex, 'hex');
            const salt = Buffer.from(saltHex, 'hex');

            const pbkdf2Promise = promisify(crypto.pbkdf2);
            const key = await pbkdf2Promise(
                secretKey,
                salt,
                this.ITERATIONS,
                this.KEY_LENGTH,
                this.DIGEST
            );

            const decipher = crypto.createDecipheriv(this.ALGORITHM, key, iv);
            let decrypted = decipher.update(encrypted, 'hex', 'utf8');
            decrypted += decipher.final('utf8');

            return decrypted;
        } catch (error) {
            throw new Error(`Decryption failed: ${error.message}`);
        }
    }

    /**
     * Compares a plain password with an encrypted one
     * @param {string} password - The plain password to compare
     * @param {string} encryptedPassword - The encrypted password
     * @param {string} secretKey - The secret key used for encryption
     * @returns {Promise<boolean>} True if passwords match
     */
    static async comparePasswords(password, encryptedPassword, secretKey) {
        try {
            const decrypted = await this.decrypt(encryptedPassword, secretKey);
            return password === decrypted;
        } catch {
            return false;
        }
    }
}

export default CryptoUtils;