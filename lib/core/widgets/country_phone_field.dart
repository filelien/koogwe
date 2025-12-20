import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';

class CountryPhoneField extends StatefulWidget {
  final TextEditingController phoneController;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final Country? initialCountry;
  final ValueChanged<Country>? onCountryChanged;

  const CountryPhoneField({
    super.key,
    required this.phoneController,
    this.label,
    this.hint,
    this.validator,
    this.initialCountry,
    this.onCountryChanged,
  });

  @override
  State<CountryPhoneField> createState() => _CountryPhoneFieldState();
}

class _CountryPhoneFieldState extends State<CountryPhoneField> {
  Country _selectedCountry = Country.parse('FR'); // Par défaut France

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? Country.parse('GF'); // Guyane par défaut
  }

  void _selectCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      favorite: const ['GF', 'FR', 'BR', 'SR', 'GY'],
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
        inputDecoration: InputDecoration(
          hintText: 'Rechercher un pays...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
        widget.onCountryChanged?.call(country);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: KoogweSpacing.xs),
        ],
        Row(
          children: [
            // Bouton sélection pays avec drapeau
            InkWell(
              onTap: () => _selectCountry(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: KoogweSpacing.md,
                  vertical: KoogweSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: KoogweSpacing.xs),
                    Text(
                      '+${_selectedCountry.phoneCode}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: KoogweSpacing.xs),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: KoogweSpacing.md),
            // Champ téléphone
            Expanded(
              child: TextFormField(
                controller: widget.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: widget.hint ?? 'Votre numéro',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: widget.validator,
              ),
            ),
          ],
        ),
        const SizedBox(height: KoogweSpacing.xs),
        Text(
          'Numéro complet : +${_selectedCountry.phoneCode} ${widget.phoneController.text}',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

