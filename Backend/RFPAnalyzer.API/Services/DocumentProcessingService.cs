using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.parser;
using System.Text;

namespace RFPAnalyzer.API.Services;

public interface IDocumentProcessingService
{
    Task<string> ExtractTextFromDocumentAsync(string filePath, string fileType);
}

public class DocumentProcessingService : IDocumentProcessingService
{
    public async Task<string> ExtractTextFromDocumentAsync(string filePath, string fileType)
    {
        return fileType.ToLower() switch
        {
            ".pdf" => await ExtractTextFromPdfAsync(filePath),
            ".docx" => await ExtractTextFromWordAsync(filePath),
            ".doc" => await ExtractTextFromWordAsync(filePath),
            _ => throw new NotSupportedException($"File type {fileType} is not supported")
        };
    }

    private async Task<string> ExtractTextFromPdfAsync(string filePath)
    {
        return await Task.Run(() =>
        {
            var text = new StringBuilder();

            using (var reader = new PdfReader(filePath))
            {
                for (int page = 1; page <= reader.NumberOfPages; page++)
                {
                    text.Append(PdfTextExtractor.GetTextFromPage(reader, page));
                }
            }

            return text.ToString();
        });
    }

    private async Task<string> ExtractTextFromWordAsync(string filePath)
    {
        return await Task.Run(() =>
        {
            var text = new StringBuilder();

            using (var doc = WordprocessingDocument.Open(filePath, false))
            {
                var body = doc.MainDocumentPart?.Document.Body;
                if (body != null)
                {
                    foreach (var paragraph in body.Descendants<Paragraph>())
                    {
                        text.AppendLine(paragraph.InnerText);
                    }
                }
            }

            return text.ToString();
        });
    }
}
